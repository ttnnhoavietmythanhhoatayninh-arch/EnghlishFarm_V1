extends SceneTree

func _initialize()->void:
 call_deferred("run")

func find_button(root:Node,label:String)->Button:
 for child in root.get_children():
  if child is Button and child.text==label:
   return child
  var nested:=find_button(child,label)
  if nested!=null:return nested
 return null

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 assert(g.V4_GUIDE_ASSETS.size()==10)
 var unique:Dictionary={}
 for path in g.V4_GUIDE_ASSETS:
  assert(not unique.has(path))
  unique[path]=true

 g.select_difficulty("normal")
 g.finish_guide()
 var ctx:Dictionary=g.current_save_context()
 assert(g.SaveManager.write_autosave(g.state.to_dict(),ctx,1001))
 assert(g.SaveManager.write_slot(1,g.state.to_dict(),ctx,1002))
 g.show_start_menu()
 await process_frame
 for label in ["Tiếp tục","Game mới","Tải game","Cài đặt","Thoát"]:
  assert(find_button(g.main_menu_box,label)!=null,"Missing start-menu button: "+label)
 var cont:=find_button(g.main_menu_box,"Tiếp tục")
 assert(cont!=null and not cont.disabled,"Continue enabled with valid autosave")

 g.start_new_game()
 assert(g.SaveManager.read_autosave().is_empty(),"New Game replaces autosave")
 assert(not g.SaveManager.read_slot(1).is_empty(),"New Game preserves manual slots")
 g.tutorial_panel.hide()
 g.dialog.hide()
 g.show_start_menu()
 await process_frame
 cont=find_button(g.main_menu_box,"Tiếp tục")
 assert(cont!=null and cont.disabled,"Continue disabled when autosave is absent")

 g.SaveManager.remove_all_v4()
 print("JOURNEY_MENU_PASSED")
 g.queue_free()
 await process_frame
 quit()
