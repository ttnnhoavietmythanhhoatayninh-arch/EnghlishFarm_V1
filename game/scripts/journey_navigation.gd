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
 if allowed(point) and is_walkable(point,12.0) and has_walkable_step(point):
  return point
 var cell:=_nearest(point,false)
 if cell.x<0:
  return Vector2.INF
 var candidate:Vector2=grid.get_point_position(cell)
 if candidate.distance_to(point)>max_distance:
  return Vector2.INF
 if not allowed(candidate) or not is_walkable(candidate,12.0):
  return Vector2.INF
 if has_walkable_step(candidate):
  return candidate
 # Search locally around the nearest cell for a center that can actually move.
 for radius in range(1,5):
  for y in range(cell.y-radius,cell.y+radius+1):
   for x in range(cell.x-radius,cell.x+radius+1):
    var c:=Vector2i(x,y)
    if not grid.region.has_point(c) or grid.is_point_solid(c):
     continue
    var p:Vector2=grid.get_point_position(c)
    if p.distance_to(point)<=max_distance and allowed(p) and is_walkable(p,12.0) and has_walkable_step(p):
     return p
 return Vector2.INF

func has_walkable_step(point:Vector2)->bool:
 for offset in [Vector2(24,0),Vector2(-24,0),Vector2(0,24),Vector2(0,-24)]:
  if allowed(point+offset) and can_travel(point,point+offset,8.0):
   return true
 return false
