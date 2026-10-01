extends Node2D
var kind:="home"
var upgraded:=false
func _draw()->void:
 draw_rect(Rect2(0,0,1280,720),Color("607866"))
 draw_rect(Rect2(165,95,950,535),Color("745441"))
 draw_rect(Rect2(185,130,910,475),Color("caa573"))
 for y in range(140,600,38):draw_line(Vector2(185,y),Vector2(1095,y),Color("b28b60"),2)
 draw_rect(Rect2(225,160,130,105),Color("83b7ba"));draw_line(Vector2(290,160),Vector2(290,265),Color("f4e4bd"),7)
 draw_rect(Rect2(450,375,265,120),Color("765641"));draw_rect(Rect2(464,365,238,90),Color("dfc18e"))
 draw_rect(Rect2(470,376,55,45),Color("eee6bd"));draw_line(Vector2(497,379),Vector2(497,418),Color("8e9c71"),2)
 if kind=="home":
  draw_rect(Rect2(815,210,150,210),Color("775844"));draw_rect(Rect2(830,235,120,160),Color("9aaf79"));draw_rect(Rect2(830,220,120,40),Color("f3e5c9"))
  if upgraded:
   draw_rect(Rect2(270,300,120,230),Color("855c40"))
   draw_rect(Rect2(535,525,250,45),Color("b66f52"))
 else:
  for x in range(400,1020,145):
   draw_rect(Rect2(x,170,100,100),Color("76573f"))
   for i in range(6):draw_rect(Rect2(x+8+i*14,183,10,65),Color("839766") if i%2 else Color("c68150"))
 draw_rect(Rect2(590,588,100,45),Color("796b55"))

 if kind=="clara":
  draw_rect(Rect2(775,170,210,240),Color("8d9d94"))
  draw_circle(Vector2(880,290),62,Color("bdc7b5"))
  draw_circle(Vector2(880,290),42,Color("687d6e"))
  for a in [0.0,PI/2,PI,PI*1.5]:draw_line(Vector2(880,290),Vector2(880,290)+Vector2(cos(a),sin(a))*35,Color("d6ddc5"),7)
 elif kind=="ben":
  draw_rect(Rect2(810,195,185,165),Color("ba8e57"))
  for x in range(820,990,28):draw_line(Vector2(x,200),Vector2(x,350),Color("89633f"),3)
  draw_line(Vector2(510,388),Vector2(550,428),Color("766351"),10)
  draw_rect(Rect2(530,415,40,20),Color("8b9992"))
 elif kind=="emma":
  for x in range(780,1000,60):
   draw_rect(Rect2(x,285,45,32),Color("f3e6c4"))
   draw_line(Vector2(x,285),Vector2(x+22,305),Color("bb885b"),2)
 elif kind=="mia":
  for x in range(790,1020,75):
   draw_rect(Rect2(x,315,60,62),Color("ad814d"))
   for j in range(3):draw_circle(Vector2(x+12+j*17,323),10,Color("d99749"))
