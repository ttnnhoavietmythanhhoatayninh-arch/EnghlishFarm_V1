extends "res://tests/test_support.gd"

const IMAGE_ROOMS=["home","lily","emma","ben","clara","tom","noah","mia"]
const EXPECTED_ACTIONS={
 "home":["learn","shop"],
 "lily":["vocabulary","reading","places"],
 "emma":["writing","writing_lesson"],
 "ben":["repair","upgrade"],
 "clara":["bank","balance"],
 "tom":["farm","farm_help"],
 "noah":["fishing","rewards"],
 "mia":["mia_order","shop"]
}

func _initialize()->void:
 call_deferred("run")

func actions_for(data:Dictionary)->Array[String]:
 var actions:Array[String]=[]
 for obj in data.objects:
  var action:=str(obj.action)
  if action not in actions:actions.append(action)
 return actions

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 g.select_difficulty("normal")
 g.finish_guide()
 g.state.level=3
 g.nav.unlocked_level=3
 g.update_world()

 # Lily must still be locked at level 1 even though she teaches outdoors.
 g.state.level=1
 g.nav.unlocked_level=1
 g.enter_room("lily")
 if not expect_test(not g.interior.visible,"Library must remain locked until level 2"):return
 g.state.level=3
 g.nav.unlocked_level=3

 for id in IMAGE_ROOMS:
  var data:Dictionary=g.interior.room_data(id)
  if not expect_test(data.has("background"),id+": V4 background path is required"):return
  var path:=str(data.background)
  if not expect_test(path.begins_with("res://game/assets/v4/rooms/"),id+": background must live in V4 room assets"):return
  if not expect_test(ResourceLoader.exists(path),id+": V4 background resource must exist: "+path):return
  if not expect_test(data.has("blockers") and data.blockers.size()>0,id+": furniture blockers are required"):return
  if not expect_test(data.has("walk_area"),id+": room walk area is required"):return
  var required:Array=EXPECTED_ACTIONS[id]
  var actual:=actions_for(data)
  for action in required:
   if not expect_test(action in actual,id+": missing interaction action "+str(action)):return

  if not expect_test(g.interior.room_background(data)!=null,id+": background must decode, not just exist"):return
  g.enter_room(id)
  await process_frame
  if not expect_test(g.current_room==id,id+": room opens"):return
  if id=="home":
   if not expect_test(g.room_npc==null,id+": home must not spawn a duplicate NPC"):return
  else:
   if not expect_test(g.room_npc!=null and is_instance_valid(g.room_npc),id+": NPC must be a separate dynamic node"):return

  var blocker:Rect2=Rect2(data.blockers[0])
  if not expect_test(not g.interior.room_point_walkable(blocker.get_center(),18.0),id+": Momo cannot walk through furniture"):return
  var clear:Vector2=g.interior.safe_room_point(Vector2(640,500),18.0)
  if not expect_test(g.interior.room_point_walkable(clear,18.0),id+": room must keep a walkable route near the door"):return

  # Click navigation must never set a target inside furniture.
  g.room_target=blocker.get_center()
  g.room_has_target=true
  g.process_room_movement(0.05)
  if not expect_test(g.interior.room_point_walkable(g.player.position,18.0),id+": movement keeps Momo outside blockers"):return

  g.leave_room()
  await process_frame
  if not expect_test(g.room_npc==null,id+": room NPC is cleared on exit"):return

 # Mia has a matching dedicated market, never a copy of another room.
 var mia:Dictionary=g.interior.room_data("mia")
 if not expect_test(str(mia.get("background","")).ends_with("08-market.png"),"Mia must have its own market artwork"):return
 g.state.level=2
 g.nav.unlocked_level=2
 g.enter_room("mia")
 await process_frame
 if not expect_test(g.current_room=="mia","Mia market still opens"):return
 if not expect_test(g.room_npc!=null and is_instance_valid(g.room_npc),"Mia is a separate dynamic NPC"):return
 g.leave_room()

 g.queue_free()
 await process_frame
 finish_test("JOURNEY_V4_ROOMS_PASSED")
