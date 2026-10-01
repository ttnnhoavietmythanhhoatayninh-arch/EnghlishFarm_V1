extends "res://game/scripts/town_navigation.gd"
var unlocked_level:=5
func allowed(point:Vector2)->bool:
 var p:=point/2.0
 if unlocked_level==1:return Rect2(120,600,440,220).has_point(p)
 if unlocked_level==2:return p.y>=280 and p.x<1200
 if unlocked_level==3:return not Rect2(1000,0,536,330).has_point(p)
 return true
func can_travel(from:Vector2,to:Vector2,clearance:float=8.0)->bool:
 return allowed(from) and allowed(to) and super.can_travel(from,to,clearance)


func safe_walkable_near(point:Vector2,max_distance:float=220.0)->Vector2:
 if not point.is_finite():
  push_warning("Cannot resolve a non-finite exit position.")
  return point
 if allowed(point) and is_walkable(point,12.0) and has_walkable_step(point):return point
 # Fine search requested by the room contract; each circle tests 32 directions.
 for radius in [5.0,15.0,30.0,50.0]:
  if radius>max_distance:continue
  for i in range(32):
   var p:Vector2=point+Vector2.from_angle(TAU*i/32.0)*radius
   if allowed(p) and is_walkable(p,12.0) and has_walkable_step(p):return p
 # Legacy exits can lie farther away. Search safe grid centers before giving up.
 var closest:=point
 var best_distance:=max_distance+0.01
 for cell in walkable_cells:
  var p:Vector2=grid.get_point_position(cell)
  var distance:=p.distance_to(point)
  if distance<best_distance and allowed(p) and is_walkable(p,12.0) and has_walkable_step(p):
   closest=p;best_distance=distance
 if best_distance<=max_distance:return closest
 push_warning("No safe exit found near "+str(point)+"; caller must keep or choose a known safe position.")
 return point

func has_walkable_step(from:Vector2,toward:Vector2=Vector2.INF)->bool:
 if not from.is_finite() or not allowed(from) or not is_walkable(from,12.0):return false
 if toward.is_finite():
  if from.distance_to(toward)<0.01:return false
  return can_travel(from,from+from.direction_to(toward)*24.0,12.0)
 for offset in [Vector2(24,0),Vector2(-24,0),Vector2(0,24),Vector2(0,-24)]:
  if can_travel(from,from+offset,12.0):return true
 return false
