extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
 root.size=Vector2i(1280,720)
 var game=load("res://game/scenes/Town.tscn").instantiate()
 game.persistence_enabled=false
 root.add_child(game)
 DirAccess.make_dir_recursive_absolute("test-output")
 for page in ["Town","Learn","Farm","Letters","Settings"]:
  game.show_page(page)
  await create_timer(0.3).timeout
  await RenderingServer.frame_post_draw
  if root.get_texture().get_image().save_png("test-output/v1-"+page.to_lower()+".png") != OK:
   quit(1);return
 print("ENGLISH_FARM_V1_SCREENSHOTS_PASSED")
 quit(0)
