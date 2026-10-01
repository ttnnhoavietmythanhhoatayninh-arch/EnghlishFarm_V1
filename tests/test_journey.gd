extends "res://tests/test_support.gd"
const S=preload("res://game/scripts/journey_state.gd")
func _initialize()->void:
 var s=S.new()
 if not expect_test(not s.onboarded and s.level==1 and s.cards==0, "test_journey.gd: not s.onboarded and s.level==1 and s.cards==0"): return
 if not expect_test(not s.choose_difficulty("invalid"), "test_journey.gd: not s.choose_difficulty(\"invalid\")"): return
 if not expect_test(s.choose_difficulty("hard") and s.difficulty=="hard", "test_journey.gd: s.choose_difficulty(\"hard\") and s.difficulty==\"hard\""): return
 if not expect_test(not s.complete_task("delivery"), "test_journey.gd: not s.complete_task(\"delivery\")"): return
 if not expect_test(not s.can_test("vocabulary"), "test_journey.gd: not s.can_test(\"vocabulary\")"): return
 s.study("vocabulary")
 if not expect_test(s.can_test("vocabulary"), "test_journey.gd: s.can_test(\"vocabulary\")"): return
 if not expect_test(s.complete_task("vocabulary"), "test_journey.gd: s.complete_task(\"vocabulary\")"): return
 if not expect_test(not s.complete_task("vocabulary"), "test_journey.gd: not s.complete_task(\"vocabulary\")"): return
 s.complete_task("reading")
 if not expect_test(s.level==1 and s.level_points()==2, "test_journey.gd: s.level==1 and s.level_points()==2"): return
 s.complete_task("harvest")
 if not expect_test(s.level==2 and s.level_points()==0, "test_journey.gd: s.level==2 and s.level_points()==0"): return
 if not expect_test(not s.deposit(1), "test_journey.gd: not s.deposit(1)"): return
 s.complete_task("delivery")
 s.complete_task("grammar")
 s.complete_task("letter")
 if not expect_test(s.level==3, "test_journey.gd: s.level==3"): return
 s.cards=10
 if not expect_test(not s.deposit(-1), "test_journey.gd: not s.deposit(-1)"): return
 if not expect_test(s.deposit(5) and s.bank_balance==5 and s.cards==5, "test_journey.gd: s.deposit(5) and s.bank_balance==5 and s.cards==5"): return
 if not expect_test(not s.withdraw(6), "test_journey.gd: not s.withdraw(6)"): return
 if not expect_test(s.withdraw(3) and s.cards==8 and s.bank_balance==2, "test_journey.gd: s.withdraw(3) and s.cards==8 and s.bank_balance==2"): return
 if not expect_test(not s.catch_fish(false), "test_journey.gd: not s.catch_fish(false)"): return
 if not expect_test(s.catch_fish(true) and s.fish==1, "test_journey.gd: s.catch_fish(true) and s.fish==1"): return
 if not expect_test(not s.catch_fish(true), "test_journey.gd: not s.catch_fish(true)"): return
 s.wood=5
 s.cards=10
 if not expect_test(s.improve_home(), "test_journey.gd: s.improve_home()"): return
 if not expect_test(not s.improve_home(), "test_journey.gd: not s.improve_home()"): return
 if not expect_test(s.level==4, "test_journey.gd: s.level==4"): return
 if not expect_test(s.expand_orchard(), "test_journey.gd: s.expand_orchard()"): return
 if not expect_test(s.buy_outfit(), "test_journey.gd: s.buy_outfit()"): return
 s.cards=10
 if not expect_test(s.buy_power(), "test_journey.gd: s.buy_power()"): return
 if not expect_test(s.level==5, "test_journey.gd: s.level==5"): return
 var p="user://test_journey.json"
 s.onboarded=true
 s.letter_draft="My saved letter"
 if not expect_test(s.save_to(p), "test_journey.gd: s.save_to(p)"): return
 var t=S.new()
 if not expect_test(t.load_from(p), "test_journey.gd: t.load_from(p)"): return
 if not expect_test(t.level==5 and t.onboarded and t.bank_balance==2 and t.letter_draft==s.letter_draft, "test_journey.gd: t.level==5 and t.onboarded and t.bank_balance==2 and t.letter_draft==s.letter_draft"): return
 DirAccess.remove_absolute(p)
 finish_test("JOURNEY_TESTS_PASSED")
