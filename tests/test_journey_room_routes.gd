extends "res://tests/test_support.gd"
const EXPECTED={"learn":"learn","shop":"shop","vocabulary":"vocabulary","reading":"reading","places":"places","mia_order":"npc","writing":"letters","writing_lesson":"writing_lesson","repair":"workshop","upgrade":"workshop","bank":"bank","balance":"balance","farm":"farm","farm_help":"farm_help","fishing":"fishing","rewards":"rewards"}
func _initialize()->void:call_deferred("run")
func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g);await process_frame
 g.select_difficulty("normal");g.finish_guide()
 g.state.level=3;g.nav.unlocked_level=3;g.update_world()
 g.show_writing()
 if not expect_test(g.screen=="writing_lesson","Writing must teach before testing"):return
 g.close_dialog();g.state.study("writing")
 g.set_process(false)
 for id in ["home","lily","mia","emma","ben","clara","tom","noah"]:
  g.enter_room(id);await process_frame
  var data:Dictionary=g.interior.room_data(id)
  for obj in data.objects:
   g.close_dialog();g.player.position=Vector2(640,480)
   if not expect_test(g.interior.room_point_walkable(obj.approach),id+": legal approach for "+str(obj.id)):return
   # Click the real artwork: no remote action before arriving.
   var click:=InputEventMouseButton.new()
   click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=Rect2(obj.rect).get_center()
   g._unhandled_input(click)
   if not expect_test(not g.dialog.visible,id+": artwork click must walk first"):return
   for tick in range(300):
    g.process_room_movement(0.05)
    if not expect_test(g.interior.room_point_walkable(g.player.position),id+": route crosses furniture"):return
    if not g.room_has_target:break
   if not expect_test(g.dialog.visible and g.screen==EXPECTED[obj.action],id+": click route did not open "+str(obj.action)+"; got "+g.screen):return
   g.close_dialog()
   # E must dispatch the same action at the reachable approach.
   g.player.position=obj.approach;g.room_interact()
   if not expect_test(g.dialog.visible and g.screen==EXPECTED[obj.action],id+": E action mismatch for "+str(obj.id)):return
   g.close_dialog()
   # Every approach must retain a route back to the door.
   g.set_room_target(Vector2(640,545))
   for tick in range(300):
    g.process_room_movement(0.05)
    if not g.room_has_target:break
   if not expect_test(g.player.position.distance_to(Vector2(640,545))<2,id+": return route blocked"):return
  if id!="home":
   g.player.position=g.interior.safe_room_point(g.room_npc.position+Vector2(-65,0))
   g.room_interact()
   if not expect_test(g.dialog.visible and g.screen=="npc",id+": E must talk to human NPC"):return
   g.close_dialog()
  var commands:Array=[]
  for b in g.command_buttons:
   if not b.visible:continue
   if not expect_test(b.position.y==620 and b.get_rect().end.x<=1280,"Toolbar layout"):return
   for state in ["normal","hover","pressed","disabled"]:
    if not expect_test(b.has_theme_stylebox(state),"Missing button state "+state):return
   commands.append(b.text)
  if not expect_test(commands==["Farm","Letters","Settings","Tasks","Map","? Help"],"Exactly six commands"):return
  # Closed dialog must not resume an old click route.
  g.set_room_target(Vector2(640,400))
  g.open_dialog("test","Pause")
  var before:Vector2=g.player.position
  g.process_room_movement(0.05)
  if not expect_test(g.player.position==before,"Dialog must freeze room movement"):return
  g.close_dialog()
  if not expect_test(not g.room_has_target,"Dialog must cancel stale route"):return
  g.leave_room()
  if not expect_test(g.player.is_physics_processing(),"Outside movement restored"):return
 g.queue_free();await process_frame
 finish_test("JOURNEY_ROOM_ROUTES_PASSED")
