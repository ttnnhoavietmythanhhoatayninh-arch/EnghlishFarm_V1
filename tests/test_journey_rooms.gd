extends SceneTree

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
  assert(r.position.x>=0 and r.position.y>=0,id+": button starts inside viewport "+str(r))
  assert(r.end.x<=1280 and r.end.y<=720,id+": button fits 1280x720 "+str(r))
  assert(r.end.y<=620,id+": room button must stay above bottom toolbar "+str(r))

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 g.select_difficulty("normal")
 g.finish_guide()
 assert(g.state.onboarded)

 for item in ROOM_CASES:
  var id:String=item.id
  g.state.level=int(item.level)
  g.nav.unlocked_level=g.state.level
  g.update_world()
  var n:Dictionary=g.npc_by_id(id)
  assert(not n.is_empty(),"Known room: "+id)

  g.dialog.hide()
  g.interior.hide()
  g.room_ui.hide()
  g.current_room=""
  g.pending_npc=""
  g.pending_door=id
  g.player.position=n.door*2

  for i in range(5):
   await process_frame
  assert(g.interior.visible,id+": pending_door opens room")
  assert(g.current_room==id,id+": current_room is stable")
  assert(g.pending_door=="" and g.pending_npc=="",id+": pending flags consumed")

  await process_frame
  var ids_before:=room_button_ids(g)
  assert(not ids_before.is_empty(),id+": room has controls")
  assert_room_buttons_fit(g,id)
  for i in range(3):
   await process_frame
  var ids_after:=room_button_ids(g)
  assert(ids_before==ids_after,id+": buttons are not recreated every frame")

  g.leave_room()
  assert(not g.interior.visible,id+": leave_room hides interior")
  assert(not g.room_ui.visible,id+": leave_room hides room UI")
  assert(not g.dialog.visible,id+": leave_room hides dialog")
  assert(g.current_room=="" and g.pending_door=="" and g.pending_npc=="",id+": leave_room clears room state")
  var expected_exit:Vector2=Vector2(n.get("exit",n.door+Vector2(0,55)))*2
  assert(g.nav.allowed(n.door*2),id+": building door must be on an allowed tile")
  assert(g.nav.allowed(expected_exit),id+": building exit must be on an allowed tile")
  assert(expected_exit.distance_to(n.door*2)>=80.0,id+": exit must be clear of the doorway")
  assert(expected_exit.distance_to(n.door*2)<=180.0,id+": exit must stay near the doorway")
  assert(g.player.position==expected_exit,id+": Momo is placed at the safe outside point")
  for i in range(30):
   await process_frame
  assert(not g.interior.visible,id+": room stays hidden after 30 frames")

 print("JOURNEY_ROOMS_PASSED")
 g.queue_free()
 await process_frame
 quit()
