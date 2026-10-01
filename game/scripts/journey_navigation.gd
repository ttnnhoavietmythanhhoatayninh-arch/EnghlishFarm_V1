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
