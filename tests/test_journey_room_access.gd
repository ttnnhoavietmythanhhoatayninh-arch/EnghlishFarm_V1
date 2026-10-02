extends "res://tests/test_support.gd"
func _initialize()->void:call_deferred("run")
func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 g.select_difficulty("normal");g.finish_guide()
 g.state.level=3;g.nav.unlocked_level=3;g.update_world()
 for id in ["home","lily","mia","emma","ben","clara","tom","noah"]:
  g.enter_room(id)
  await process_frame
  var data:Dictionary=g.interior.room_data(id)
  # Every advertised E action must be reachable from a legal floor position.
  for obj in data.objects:
   var reachable:=false
   for y in range(330,520,10):
    for x in range(60,1220,10):
     var pt:=Vector2(x,y)
     if not g.interior.room_point_walkable(pt):continue
     g.player.position=pt
     var near:Dictionary=g.nearest_room_object()
     if str(near.get("id",""))==str(obj.id):reachable=true;break
    if reachable:break
   if not expect_test(reachable,id+": E cannot reach "+str(obj.id)):return
  if id!="home":
   if not expect_test(g.interior.room_point_walkable(g.room_npc.position),id+": NPC must stand outside furniture"):return
  g.leave_room()
 g.queue_free();await process_frame
 finish_test("JOURNEY_ROOM_ACCESS_PASSED")
