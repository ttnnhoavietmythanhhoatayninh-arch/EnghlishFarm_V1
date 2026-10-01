extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var game=load("res://game/scenes/Town.tscn").instantiate()
 game.persistence_enabled=false
 root.add_child(game)
 await process_frame
 assert(game.NPCS.size()==6)
 assert(game.state.accept_order())
 game.show_page("Learn")
 game.inputs[0].text="carrots";game.inputs[1].text="morning";game.inputs[2].text="three"
 game.check_reading()
 assert(game.state.seeds==3)
 for i in range(3):
  game.farm_action("plant",i)
  game.state.plots[i].planted_at-=43201
  game.farm_action("harvest",i)
 assert(game.state.produce==3)
 assert(game.state.deliver_order())
 assert(game.state.upgrade_tools())
 game.show_page("Letters")
 game.writing.text="Dear Mia, I will bring three carrots tomorrow. Best wishes, Momo."
 game.writing.text_changed.emit()
 game.show_page("Town")
 game.show_page("Letters")
 assert(game.writing.text==game.state.letter_draft)
 var path="user://test_town_save.json"
 assert(game.state.save_to(path))
 var other=load("res://game/scripts/town_state.gd").new()
 assert(other.load_from(path))
 assert(other.order_stage==2 and other.tool_level==2 and other.letter_draft==game.writing.text)
 DirAccess.remove_absolute(path)
 game.close_panel()
 game.player.position=game.NPCS[0].at*2
 assert(game.nearest_npc()==0)
 game.toggle_map();assert(game.map_panel.visible)
 game.toggle_map();assert(not game.map_panel.visible)
 print("TOWN_UI_TESTS_PASSED")
 game.queue_free();await process_frame;quit()
