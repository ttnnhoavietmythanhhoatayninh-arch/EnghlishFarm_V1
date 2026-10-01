extends SceneTree
func _initialize()->void:call_deferred("run")
func verify(g)->void:
 await process_frame;await process_frame
 var r:Rect2=g.dialog.get_global_rect()
 assert(r.position.x>=0 and r.end.x<=1280 and r.end.y<=720,"Dialog must fit viewport: "+str(r))
 var box:StyleBoxFlat=g.dialog.get_theme_stylebox("panel")
 assert(box.bg_color.r>0.8 and box.bg_color.g>0.8,"Light parchment panel")
 assert(g.close_button.get_global_rect().end.x<=1280)
func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate();g.persistence_enabled=false;root.add_child(g)
 await process_frame
 await verify(g)
 assert(g.SaveManager.ensure_root(),"V4 save folder must be writable")
 assert(g.SaveManager.write_autosave(g.state.to_dict(),{"world_player_position":Vector2(400,1380)},123),"Reset probe autosave must be writable")
 assert(FileAccess.file_exists(g.SaveManager.AUTOSAVE),"Reset probe autosave exists")
 assert(g.SaveManager.remove_autosave(),"Reset must remove autosave family")
 assert(not FileAccess.file_exists(g.SaveManager.AUTOSAVE),"Autosave must be gone after reset")
 g.select_difficulty("easy")
 assert(g.GUIDE_PAGES.size()==9,"V4 guide must contain 9 steps")
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
 for child in g.body.get_children():
  if child is Button and "Reset phiên hiện tại" in child.text:reset_found=true
 assert(reset_found,"Settings must expose Reset data button")
 g.show_reset_confirm();await verify(g)
 g.show_farm();await verify(g)
 g.show_places();await verify(g)
 for level in [1,2,3,4]:
  g.state.level=level;g.changed()
  for npc in g.npc_data:
   if npc.level>level:continue
   assert(g.nav.allowed(npc.at*2))
   assert(not g.nav.find_path(g.player.position,npc.at*2).is_empty(),"Reach NPC: "+npc.id+" level "+str(level))
  g.show_tasks();await verify(g)
 g.show_bank();await verify(g)
 g.show_fishing();await verify(g)
 g.state.text_size=24;g.show_grammar();await verify(g)
 print("JOURNEY_LAYOUT_PASSED")
 g.queue_free();await process_frame;quit()
