extends Node2D
func _draw()->void:
 draw_rect(Rect2(-62,-55,86,43),Color("a87443"))
 draw_rect(Rect2(20,-48,40,36),Color("71997a"))
 draw_rect(Rect2(30,-43,25,17),Color("d1e3dc"))
 for x in [-41,37]:
  draw_circle(Vector2(x,-8),13,Color("443d38"));draw_circle(Vector2(x,-8),6,Color("b1b3a4"))
 for x in [-49,-26,-3]:
  draw_rect(Rect2(x,-69,16,21),Color("dd8b45"));draw_line(Vector2(x+7,-69),Vector2(x+5,-79),Color("6d9853"),4)
 draw_rect(Rect2(-65,-22,129,9),Color("d9c19a"))
