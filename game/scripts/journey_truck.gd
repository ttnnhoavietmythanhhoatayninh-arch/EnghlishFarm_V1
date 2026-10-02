extends Node2D

var wheel_phase:=0.0
var bounce_phase:=0.0
var facing_right:=true

func set_motion(delta_move:Vector2,delta:float)->void:
 if delta_move.length()>0.1:
  facing_right=delta_move.x>=0.0 if abs(delta_move.x)>0.2 else facing_right
  wheel_phase=fmod(wheel_phase+delta_move.length()*0.08,TAU)
  bounce_phase=fmod(bounce_phase+delta*10.0,TAU)
  scale.x=abs(scale.x)*(1.0 if facing_right else -1.0)
  queue_redraw()


func _draw()->void:
 var bob:=sin(bounce_phase)*1.5
 var wheel_y:=sin(wheel_phase)*1.2
 # Soft shadow.
 draw_ellipse(Vector2(0,10),Vector2(72,14),Color(0.18,0.15,0.12,0.28))

 # Wooden cargo bed.
 draw_rect(Rect2(-72,-55+bob,88,48),Color("7a4f31"))
 draw_rect(Rect2(-68,-51+bob,80,40),Color("b57a45"))
 draw_rect(Rect2(-70,-57+bob,84,8),Color("d2a060"))
 draw_rect(Rect2(-70,-18+bob,84,7),Color("60402c"))
 for x in [-58,-31,-4]:
  draw_rect(Rect2(x,-51+bob,5,34),Color("8a5a36"))

 # Three carrot crates.
 for x in [-59,-33,-7]:
  draw_rect(Rect2(x,-74+bob,22,22),Color("9a653d"))
  draw_rect(Rect2(x+2,-72+bob,18,18),Color("c88a4f"))
  draw_circle(Vector2(x+7,-66+bob),6,Color("e8873d"))
  draw_circle(Vector2(x+15,-63+bob),6,Color("e8873d"))
  draw_line(Vector2(x+7,-72+bob),Vector2(x+4,-81+bob),Color("6f9b58"),4)
  draw_line(Vector2(x+14,-70+bob),Vector2(x+17,-80+bob),Color("7ca55d"),4)

 # Sage-green cabin.
 draw_rect(Rect2(14,-51+bob,48,44),Color("557a66"))
 draw_rect(Rect2(19,-57+bob,38,8),Color("efe0b8"))
 draw_rect(Rect2(20,-46+bob,35,21),Color("6f9b8c"))
 draw_rect(Rect2(24,-43+bob,27,15),Color("cfe3dd"))
 draw_line(Vector2(37,-43+bob),Vector2(37,-28+bob),Color("557a66"),3)
 draw_rect(Rect2(48,-20+bob,15,9),Color("d9b05f"))
 draw_rect(Rect2(11,-16+bob,53,8),Color("3f584b"))

 # Chassis / bumper.
 draw_rect(Rect2(-75,-12+bob,143,8),Color("d7b67f"))
 draw_rect(Rect2(-66,-5+bob,128,6),Color("54473d"))
 draw_rect(Rect2(62,-11+bob,8,9),Color("c66f4a"))

 # Wheels animate slightly while driving.
 for x in [-48,40]:
  draw_circle(Vector2(x,wheel_y),15,Color("352f2c"))
  draw_circle(Vector2(x,wheel_y),9,Color("6b665e"))
  var spoke:=Vector2(cos(wheel_phase),sin(wheel_phase))*6
  draw_line(Vector2(x,wheel_y)-spoke,Vector2(x,wheel_y)+spoke,Color("d6b370"),3)
  draw_circle(Vector2(x,wheel_y),4,Color("d6b370"))

 draw_circle(Vector2(62,-34+bob),5,Color("f4d77f"))
 draw_circle(Vector2(62,-34+bob),2,Color("fff1b0"))

func draw_ellipse(center:Vector2,radius:Vector2,color:Color)->void:
 var points:=PackedVector2Array()
 for i in range(24):
  var a:=TAU*float(i)/24.0
  points.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y))
 draw_colored_polygon(points,color)
