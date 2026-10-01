extends "res://tests/test_support.gd"
func _initialize()->void:call_deferred("run")
func run()->void:
 var game=load("res://game/scenes/Town.tscn").instantiate()
 game.persistence_enabled=false
 root.add_child(game)
 await process_frame
 if not expect_test(game.NPCS.size()==6, "test_town_ui.gd: game.NPCS.size()==6"): return
 if not expect_test(game.state.accept_order(), "test_town_ui.gd: game.state.accept_order()"): return
 game.show_page("Learn")
 game.inputs[0].text="carrots"
 game.inputs[1].text="morning"
 game.inputs[2].text="three"
 game.check_reading()
 if not expect_test(game.state.seeds==3, "test_town_ui.gd: game.state.seeds==3"): return
 for i in range(3):
  game.farm_action("plant",i)
  game.state.plots[i].planted_at-=43201
  game.farm_action("harvest",i)
 if not expect_test(game.state.produce==3, "test_town_ui.gd: game.state.produce==3"): return
 if not expect_test(game.state.deliver_order(), "test_town_ui.gd: game.state.deliver_order()"): return
 if not expect_test(game.state.upgrade_tools(), "test_town_ui.gd: game.state.upgrade_tools()"): return
 game.show_page("Letters")
 game.writing.text="Dear Mia, I will bring three carrots tomorrow. Best wishes, Momo."
 game.writing.text_changed.emit()
 game.show_page("Town")
 game.show_page("Letters")
 if not expect_test(game.writing.text==game.state.letter_draft, "test_town_ui.gd: game.writing.text==game.state.letter_draft"): return
 var path="user://test_town_save.json"
 if not expect_test(game.state.save_to(path), "test_town_ui.gd: game.state.save_to(path)"): return
 var other=load("res://game/scripts/town_state.gd").new()
 if not expect_test(other.load_from(path), "test_town_ui.gd: other.load_from(path)"): return
 if not expect_test(other.order_stage==2 and other.tool_level==2 and other.letter_draft==game.writing.text, "test_town_ui.gd: other.order_stage==2 and other.tool_level==2 and other.letter_draft==game.writing.text"): return
 DirAccess.remove_absolute(path)
 game.close_panel()
 game.player.position=game.NPCS[0].at*2
 if not expect_test(game.nearest_npc()==0, "test_town_ui.gd: game.nearest_npc()==0"): return
 game.toggle_map()
 if not expect_test(game.map_panel.visible, "test_town_ui.gd: game.map_panel.visible"): return
 game.toggle_map()
 if not expect_test(not game.map_panel.visible, "test_town_ui.gd: not game.map_panel.visible"): return
 game.queue_free()
 await process_frame
 finish_test("TOWN_UI_TESTS_PASSED")
