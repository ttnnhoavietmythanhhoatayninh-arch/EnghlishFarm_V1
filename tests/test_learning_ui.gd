extends "res://tests/test_support.gd"
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var game = load("res://game/scenes/LearningV1.tscn").instantiate()
 game.persistence_enabled = false
 root.add_child(game)
 await process_frame
 if not expect_test(game.inputs.size() == 3, "test_learning_ui.gd: game.inputs.size() == 3"): return
 game.inputs[0].text="carrot seeds"
 game.inputs[1].text="morning"
 game.inputs[2].text="three"
 game.check_reading()
 if not expect_test(game.state.seeds == 3, "test_learning_ui.gd: game.state.seeds == 3"): return
 game.check_reading()
 if not expect_test(game.state.seeds == 3, "test_learning_ui.gd: game.state.seeds == 3"): return
 game.show_page("Farm")
 game.farm_action("plant",0)
 if not expect_test(game.state.seeds == 2, "test_learning_ui.gd: game.state.seeds == 2"): return
 game.show_page("Letters")
 if not expect_test(game.player.locked, "test_learning_ui.gd: game.player.locked"): return
 game.show_page("Settings")
 if not expect_test(not game.player.locked, "test_learning_ui.gd: not game.player.locked"): return
 for mode in ["easy","normal","hard"]:
  game.state.difficulty=mode
  game.show_page("Learn")
  if not expect_test(game.inputs.size()==3, "test_learning_ui.gd: game.inputs.size()==3"): return
 game.queue_free()
 await process_frame
 finish_test("LEARNING_UI_TESTS_PASSED")
