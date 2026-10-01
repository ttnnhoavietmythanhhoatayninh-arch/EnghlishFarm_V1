extends "res://tests/test_support.gd"
const Nav=preload("res://game/scripts/town_navigation.gd")
const State=preload("res://game/scripts/town_state.gd")
func _initialize() -> void:
 var nav=Nav.new()
 var spawn=Vector2(780,560)*2
 for pos in [Vector2(438,307),Vector2(480,580),Vector2(920,580),Vector2(275,520),Vector2(1090,751),Vector2(1340,781),Vector2(200,690),Vector2(800,910)]:
  if not expect_test(nav.is_walkable(pos*2),"Destination walkable: "+str(pos)): return
  if not expect_test(not nav.find_path(spawn,pos*2).is_empty(),"Destination connected: "+str(pos)): return
 if not expect_test(not nav.is_walkable(Vector2(700,475)*2),"Fountain collision"): return
 var s=State.new()
 if not expect_test(s.accept_order(), "test_town.gd: s.accept_order()"): return
 if not expect_test(not s.deliver_order(), "test_town.gd: not s.deliver_order()"): return
 s.produce=3
 if not expect_test(s.deliver_order(), "test_town.gd: s.deliver_order()"): return
 var cards=s.cards
 if not expect_test(not s.deliver_order() and s.cards==cards, "test_town.gd: not s.deliver_order() and s.cards==cards"): return
 if not expect_test(s.wood==5 and s.friendship.get("mia")==1, "test_town.gd: s.wood==5 and s.friendship.get(\"mia\")==1"): return
 if not expect_test(s.upgrade_tools(), "test_town.gd: s.upgrade_tools()"): return
 if not expect_test(not s.upgrade_tools(), "test_town.gd: not s.upgrade_tools()"): return
 finish_test("TOWN_TESTS_PASSED")
