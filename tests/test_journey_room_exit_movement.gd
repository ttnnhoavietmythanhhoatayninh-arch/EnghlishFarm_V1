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

func first_world_step(g,at:Vector2)->Vector2:
 for offset in [Vector2(24,0),Vector2(-24,0),Vector2(0,24),Vector2(0,-24)]:
  if g.nav.allowed(at+offset) and g.nav.can_travel(at,at+offset,8.0):
   return offset
 return Vector2.ZERO

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 g.select_difficulty("normal")
 g.finish_guide()

 for item in ROOM_CASES:
  var id:String=item.id
  g.state.level=int(item.level)
  g.nav.unlocked_level=g.state.level
  g.update_world()
  g.dialog.hide()
  g.enter_room(id)
  assert(g.interior.visible,id+": room opens")

  var data:Dictionary=g.interior.room_data(id)
  for obj in data.objects:
   assert(not g.room_position_walkable(Rect2(obj.rect).get_center(),data),id+": furniture center must block Momo")
  assert(g.room_position_walkable(Vector2(640,500),data),id+": spawn lane must remain walkable")

  g.leave_room()
  assert(not g.interior.visible,id+": room closes")
  assert(not g.player.locked,id+": player is unlocked after leave")
  var start:Vector2=g.player.global_position
  var step:=first_world_step(g,start)
  assert(step!=Vector2.ZERO,id+": exit must have a real movement step")
  assert(g.player._move(step,false),id+": CharacterBody movement succeeds after leave")
  assert(g.player.global_position.distance_to(start)>1.0,id+": Momo actually changes position after leave")

 print("JOURNEY_ROOM_EXIT_MOVEMENT_PASSED")
 g.queue_free()
 await process_frame
 quit()
