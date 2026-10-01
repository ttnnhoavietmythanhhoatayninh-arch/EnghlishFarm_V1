extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var game = load("res://game/scenes/LearningV1.tscn").instantiate()
 game.persistence_enabled = false
 root.add_child(game)
 await process_frame
 assert(game.inputs.size() == 3)
 game.inputs[0].text="carrot seeds"
 game.inputs[1].text="morning"
 game.inputs[2].text="three"
 game.check_reading()
 assert(game.state.seeds == 3)
 game.check_reading()
 assert(game.state.seeds == 3)
 game.show_page("Farm")
 game.farm_action("plant",0)
 assert(game.state.seeds == 2)
 game.show_page("Letters")
 assert(game.player.locked)
 game.show_page("Settings")
 assert(not game.player.locked)
 for mode in ["easy","normal","hard"]:
  game.state.difficulty=mode
  game.show_page("Learn")
  assert(game.inputs.size()==3)
 print("Learning UI integration: passed")
 game.queue_free()
 await process_frame
 quit(0)
