extends Node2D

func _draw()->void:
 # Soft pixel-art shadow.
 draw_ellipse(Vector2(0,8),Vector2(70,14),Color(0.18,0.15,0.12,0.28))

 # Wooden cargo bed with warm rails.
 draw_rect(Rect2(-72,-55,88,48),Color("7a4f31"))
 draw_rect(Rect2(-68,-51,80,40),Color("b57a45"))
 draw_rect(Rect2(-70,-57,84,8),Color("d2a060"))
 draw_rect(Rect2(-70,-18,84,7),Color("60402c"))
 for x in [-58,-31,-4]:
  draw_rect(Rect2(x,-51,5,34),Color("8a5a36"))

 # Three carrot crates so the delivery is readable at a glance.
 for x in [-59,-33,-7]:
  draw_rect(Rect2(x,-74,22,22),Color("9a653d"))
  draw_rect(Rect2(x+2,-72,18,18),Color("c88a4f"))
  draw_circle(Vector2(x+7,-66),6,Color("e8873d"))
  draw_circle(Vector2(x+15,-63),6,Color("e8873d"))
  draw_line(Vector2(x+7,-72),Vector2(x+4,-81),Color("6f9b58"),4)
  draw_line(Vector2(x+14,-70),Vector2(x+17,-80),Color("7ca55d"),4)

 # Sage-green cabin and cream roof.
 draw_rect(Rect2(14,-51,48,44),Color("557a66"))
 draw_rect(Rect2(19,-57,38,8),Color("efe0b8"))
 draw_rect(Rect2(20,-46,35,21),Color("6f9b8c"))
 draw_rect(Rect2(24,-43,27,15),Color("cfe3dd"))
 draw_line(Vector2(37,-43),Vector2(37,-28),Color("557a66"),3)
 draw_rect(Rect2(48,-20,15,9),Color("d9b05f"))
 draw_rect(Rect2(11,-16,53,8),Color("3f584b"))

 # Bumper and chassis.
 draw_rect(Rect2(-75,-12,143,8),Color("d7b67f"))
 draw_rect(Rect2(-66,-5,128,6),Color("54473d"))
 draw_rect(Rect2(62,-11,8,9),Color("c66f4a"))

 # Wheels with warm hubs.
 for x in [-48,40]:
  draw_circle(Vector2(x,0),15,Color("352f2c"))
  draw_circle(Vector2(x,0),9,Color("6b665e"))
  draw_circle(Vector2(x,0),4,Color("d6b370"))

 # Tiny front light.
 draw_circle(Vector2(62,-34),5,Color("f4d77f"))
 draw_circle(Vector2(62,-34),2,Color("fff1b0"))

func draw_ellipse(center:Vector2,radius:Vector2,color:Color)->void:
 var points:=PackedVector2Array()
 for i in range(24):
  var a:=TAU*float(i)/24.0
  points.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y))
 draw_colored_polygon(points,color)
