extends SceneTree
const Nav=preload("res://game/scripts/town_navigation.gd")
const State=preload("res://game/scripts/town_state.gd")
func _initialize() -> void:
 var nav=Nav.new()
 var spawn=Vector2(780,560)*2
 for pos in [Vector2(438,307),Vector2(480,580),Vector2(920,580),Vector2(275,520),Vector2(1090,751),Vector2(1340,781),Vector2(200,690),Vector2(800,910)]:
  assert(nav.is_walkable(pos*2),"Destination walkable: "+str(pos))
  assert(not nav.find_path(spawn,pos*2).is_empty(),"Destination connected: "+str(pos))
 assert(not nav.is_walkable(Vector2(700,475)*2),"Fountain collision")
 var s=State.new()
 assert(s.accept_order())
 assert(not s.deliver_order())
 s.produce=3
 assert(s.deliver_order())
 var cards=s.cards
 assert(not s.deliver_order() and s.cards==cards)
 assert(s.wood==5 and s.friendship.get("mia")==1)
 assert(s.upgrade_tools())
 assert(not s.upgrade_tools())
 print("TOWN_TESTS_PASSED")
 quit()
