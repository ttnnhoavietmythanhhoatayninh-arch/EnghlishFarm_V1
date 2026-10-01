extends SceneTree
const State = preload("res://game/scripts/learning_state.gd")
var failures := 0
func check(condition: bool, message: String) -> void:
 if not condition:
  failures += 1
  printerr(message)
func _initialize() -> void:
 var s = State.new()
 check(s.learn_word("seed", 100000), "first word rewarded")
 check(not s.learn_word("seed", 100001), "duplicate word not rewarded")
 check(s.cards == 1, "no duplicate cards")
 s.learn_word("water", 100002)
 s.learn_word("soil", 100003)
 check(s.cards == 6, "3 words plus daily bonus")
 check(not s.review_word("seed", 100004), "review not due")
 check(s.review_word("seed", 186401), "next day review")
 check(not s.review_word("seed", 186402), "duplicate review blocked")
 check(s.claim_login(200000) == 1, "first login")
 check(s.claim_login(200001) == 0, "one login reward per day")
 check(s.claim_login(286400) == 2, "streak increases")
 check(s.unlock_seeds("carrot-easy", 3, 3), "reading unlock")
 check(not s.unlock_seeds("carrot-easy", 3, 3), "no duplicate seed pack")
 check(s.plant(0, 300000), "plant seed")
 check(s.crop_status(0, 343201) == "wilted", "12h missed watering")
 check(s.harvest(0, 400000) == 0, "wilted crop not harvested")
 s.plant(0, 500000)
 check(s.water(0, 540000), "water living crop")
 check(s.harvest(0, 544000) == 2, "ready watered crop harvested")
 check(s.harvest(0, 544001) == 0, "no double harvest")
 s.cards = 0
 for i in range(3): s.challenge(false, 600000+i)
 check(s.cards == 0, "cannot have negative cards")
 check(s.blocked_until == 601802, "three failures cooldown")
 check(not s.challenge(true, 600004), "cooldown blocks reward")
 check(s.spend_power(), "hint consumes power")
 s.powers = 0
 check(not s.spend_power(), "no negative powers")
 var path = "user://test_learning_v1.json"
 check(s.save_to(path), "save works")
 var restored = State.new()
 check(restored.load_from(path), "load works")
 check(restored.cards == s.cards and restored.learned == s.learned, "round trip")
 var f = FileAccess.open(path, FileAccess.WRITE)
 f.store_string("not-json"); f.close()
 check(not restored.load_from(path), "corrupt save rejected")
 DirAccess.remove_absolute(path)
 print("Learning state failures: ", failures)
 quit(failures)
