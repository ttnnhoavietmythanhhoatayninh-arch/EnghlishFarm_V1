extends "res://tests/test_support.gd"
func _initialize()->void:call_deferred("run")
func verify(g)->void:
 await process_frame;await process_frame
 var r:Rect2=g.dialog.get_global_rect()
 if not expect_test(r.position.x>=0 and r.end.x<=1280 and r.end.y<=720,"Dialog must fit viewport: "+str(r)):return
 var box:StyleBoxFlat=g.dialog.get_theme_stylebox("panel")
 if not expect_test(box.bg_color.r>0.8 and box.bg_color.g>0.8,"Light parchment panel"):return
 if not expect_test(g.close_button.get_global_rect().end.x<=1280):return
func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate();g.persistence_enabled=false;root.add_child(g)
 await process_frame
 await verify(g)
 g.select_difficulty("easy")
 if not expect_test(g.GUIDE_PAGES.size()==9,"V4 guide must contain 9 steps"):return
 for i in range(g.GUIDE_PAGES.size()):g.show_guide(i);await verify(g)
 g.finish_guide()
 for mode in ["easy","normal","hard"]:
  g.state.choose_difficulty(mode)
  for i in range(3):g.show_vocabulary(i);await verify(g)
  g.show_grammar();await verify(g)
  g.show_reading();await verify(g)
  g.show_writing_lesson();await verify(g)
 g.show_settings();await verify(g)
 var reset_found:=false
 var slot_controls:=0
 for child in g.body.get_children():
  if child is Button and "Reset phiên hiện tại" in child.text:reset_found=true
  if child is HBoxContainer:slot_controls+=1
 if not expect_test(reset_found,"Settings must expose Reset current session button"):return
 if not expect_test(slot_controls>=3,"Settings must expose three manual save slots"):return
 var Saves=preload("res://game/scripts/journey_save_manager.gd")
 Saves.remove_all_v4()
 g.state.cards=17
 if not expect_test(Saves.write_slot(1,g.state.to_dict(),g.current_save_context(),123456),"Manual slot save must succeed"):return
 g.state.cards=1
 g.load_manual_slot(1)
 if not expect_test(g.state.cards==17,"Loading slot must restore saved Cards"):return
 g.show_load_slot_confirm(1);await verify(g)
 g.show_settings();await verify(g)
 g.show_reset_confirm();await verify(g)
 Saves.remove_all_v4()
 g.show_farm();await verify(g)
 g.show_places();await verify(g)
 for level in [1,2,3,4]:
  g.state.level=level;g.changed()
  for npc in g.npc_data:
   if npc.level>level:continue
   if not expect_test(g.nav.allowed(npc.at*2)):return
   if not expect_test(not g.nav.find_path(g.player.position,npc.at*2).is_empty(),"Reach NPC: "+npc.id+" level "+str(level)):return
  g.show_tasks();await verify(g)
 g.show_bank();await verify(g)
 g.show_fishing();await verify(g)
 g.state.text_size=24;g.show_grammar();await verify(g)

 g.queue_free();await process_frame;finish_test("JOURNEY_LAYOUT_PASSED")
