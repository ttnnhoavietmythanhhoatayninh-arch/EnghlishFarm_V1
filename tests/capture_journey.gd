extends SceneTree

func _initialize()->void:
 call_deferred("capture")

func shot(name:String)->void:
 await create_timer(0.3).timeout
 await RenderingServer.frame_post_draw
 if root.get_texture().get_image().save_png("test-output/v3-"+name+".png")!=OK:
  quit(1)

func capture()->void:
 root.size=Vector2i(1280,720)
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 DirAccess.make_dir_recursive_absolute("test-output")
 await shot("difficulty")

 g.select_difficulty("easy")
 for i in range(3):
  g.show_guide(i)
  await shot("guide-"+str(i+1))
 g.finish_guide()
 await shot("starter")

 g.show_vocabulary(0)
 await shot("vocabulary")
 g.show_grammar()
 await shot("grammar")
 g.close_dialog()
 g.toggle_map()
 await shot("minimap")
 g.map_panel.hide()

 g.state.level=4
 g.nav.unlocked_level=4
 g.update_world()
 for id in ["home","lily","mia","emma","ben","clara","tom","noah"]:
  g.enter_room(id)
  await shot("room-"+id)
  if id=="mia":
   g.interact_npc("mia")
   await shot("room-mia-dialog")
   g.close_dialog()
  g.leave_room()

 print("JOURNEY_SCREENSHOTS_PASSED")
 quit(0)
