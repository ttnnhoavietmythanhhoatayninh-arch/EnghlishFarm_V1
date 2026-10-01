extends "res://tests/test_support.gd"
func _initialize()->void:
 var nav=load("res://game/scripts/journey_navigation.gd").new()
 nav.unlocked_level=5
 for rect in nav.OBSTACLES:
  for u in [0.2,0.5,0.8]:
   for v in [0.2,0.5,0.8]:
    var point:Vector2=(rect.position+rect.size*Vector2(u,v))*2
    if not expect_test(not nav.is_walkable(point),"Obstacle must block "+str(point)):return
 var safe:Vector2=nav.safe_walkable_near(Vector2(1020,756)*2+Vector2(0,110))
 if not expect_test(nav.is_walkable(safe,12),"Post office exit is safe"):return
 var did_step:=false
 for delta in [Vector2(24,0),Vector2(-24,0),Vector2(0,24),Vector2(0,-24)]:
  if nav.has_walkable_step(safe,safe+delta):did_step=true
 if not expect_test(did_step,"Directional step exists at safe exit"):return
 if not expect_test(not nav.has_walkable_step(Vector2(980,650)*2,Vector2(1000,650)*2),"Cannot step while inside post office roof"):return
 var blocked_route:PackedVector2Array=nav.find_path(Vector2(1090,751)*2,Vector2(1340,781)*2)
 if not expect_test(not blocked_route.is_empty(),"East corridor to Noah remains connected"):return
 finish_test("JOURNEY_OBSTACLES_PASSED")
