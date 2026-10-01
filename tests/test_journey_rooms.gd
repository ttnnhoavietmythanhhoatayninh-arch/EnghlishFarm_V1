extends "res://tests/test_support.gd"

const ROOM_CASES=[
 {"id":"home","level":1},
 {"id":"tom","level":1},
 {"id":"lily","level":2},
 {"id":"mia","level":2},
 {"id":"emma","level":2},
 {"id":"ben","level":3},
 {"id":"clara","level":3},
 {"id":"noah","level":3}
]

func _initialize()->void:
 call_deferred("run")

func room_button_ids(g)->Array[int]:
 var ids:Array[int]=[]
 for child in g.room_ui.get_children():
  if child is Button:
   ids.append(child.get_instance_id())
 return ids

func assert_room_buttons_fit(g,id:String)->void:
 for child in g.room_ui.get_children():
  if not child is Button:continue
  var r:Rect2=child.get_global_rect()
  if not expect_test(r.position.x>=0 and r.position.y>=0,id+": button starts inside viewport "+str(r)):return
  if not expect_test(r.end.x<=1280 and r.end.y<=720,id+": button fits 1280x720 "+str(r)):return
  if not expect_test(r.end.y<=620,id+": room button must stay above bottom toolbar "+str(r)):return

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 g.select_difficulty("normal")
 g.finish_guide()
 if not expect_test(g.state.onboarded):return

 for item in ROOM_CASES:
  var id:String=item.id
  g.state.level=int(item.level)
  g.nav.unlocked_level=g.state.level
  g.update_world()
  var n:Dictionary=g.npc_by_id(id)
  if not expect_test(not n.is_empty(),"Known room: "+id):return

  g.dialog.hide()
  g.interior.hide()
  g.room_ui.hide()
  g.current_room=""
  g.pending_npc=""
  g.pending_door=id
  if not expect_test(g.nav.is_walkable(n.door*2,12.0),id+": door must be walkable"):return
  g.player.position=n.door*2

  for i in range(5):
   await process_frame
  if not expect_test(g.interior.visible,id+": pending_door opens room"):return
  if not expect_test(g.current_room==id,id+": current_room is stable"):return
  if not expect_test(g.pending_door=="" and g.pending_npc=="",id+": pending flags consumed"):return

  await process_frame
  var ids_before:=room_button_ids(g)
  if not expect_test(not ids_before.is_empty(),id+": room has controls"):return
  assert_room_buttons_fit(g,id)
  var visible_commands:Array[String]=[]
  for b in g.command_buttons:
   if b.visible:visible_commands.append(b.text)
  if not expect_test(visible_commands==["Farm","Letters","Settings","Tasks","Map","? Help"],id+": V4 room toolbar must be fixed"):return
  g.toggle_map()
  if not expect_test(g.map_panel.visible,id+": Map button must work as view-only inside room"):return
  g.toggle_map()
  if not expect_test(not g.map_panel.visible,id+": Map closes again"):return
  var data:Dictionary=g.interior.room_data(id)
  if not expect_test(data.objects.size()>=2,id+": room must have distinct interactive furnishings"):return
  if id!="lily":
   for obj in data.objects:
    if not expect_test("sách" not in str(obj.label).to_lower(),id+": only Library may use book shelving"):return
  for i in range(3):
   await process_frame
  var ids_after:=room_button_ids(g)
  if not expect_test(ids_before==ids_after,id+": buttons are not recreated every frame"):return

  g.leave_room()
  if not expect_test(not g.interior.visible,id+": leave_room hides interior"):return
  if not expect_test(not g.room_ui.visible,id+": leave_room hides room UI"):return
  if not expect_test(not g.dialog.visible,id+": leave_room hides dialog"):return
  if not expect_test(g.current_room=="" and g.pending_door=="" and g.pending_npc=="",id+": leave_room clears room state"):return
  var requested_exit:Vector2=n.door*2+Vector2(0,110)
  var expected_exit:Vector2=g.nav.safe_walkable_near(requested_exit)
  if not expect_test(expected_exit.is_finite(),id+": exit must resolve to a walkable point"):return
  if not expect_test(g.nav.allowed(expected_exit),id+": resolved exit must be in the unlocked region"):return
  if not expect_test(g.nav.is_walkable(expected_exit,12.0),id+": resolved exit must be on the real walkable surface"):return
  if not expect_test(g.nav.has_walkable_step(expected_exit),id+": Momo must be able to take a step after leaving"):return
  if not expect_test(not g.player.locked,id+": Momo must be unlocked immediately after leaving"):return
  if not expect_test(g.player.global_position==expected_exit,id+": Momo is placed at the resolved safe point"):return
  for i in range(30):
   await process_frame
  if not expect_test(not g.interior.visible,id+": room stays hidden after 30 frames"):return


 g.queue_free()
 await process_frame
 finish_test("JOURNEY_ROOMS_PASSED")
