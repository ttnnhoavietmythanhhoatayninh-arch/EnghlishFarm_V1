extends Node2D

const TRUCK_TEXTURE=preload("res://game/assets/vehicles/carrot_delivery_truck.svg")

var wheel_phase:=0.0
var bounce_phase:=0.0
var facing_right:=true
var sprite:Sprite2D

func _ready()->void:
 sprite=Sprite2D.new()
 sprite.texture=TRUCK_TEXTURE
 sprite.centered=true
 sprite.position=Vector2(0,-8)
 sprite.scale=Vector2(0.42,0.42)
 add_child(sprite)
 queue_redraw()

func set_motion(delta_move:Vector2,delta:float)->void:
 if delta_move.length()<=0.1:return
 if abs(delta_move.x)>0.2:facing_right=delta_move.x>=0.0
 wheel_phase=fmod(wheel_phase+delta_move.length()*0.08,TAU)
 bounce_phase=fmod(bounce_phase+delta*10.0,TAU)
 if is_instance_valid(sprite):
  sprite.scale=Vector2((0.42 if facing_right else -0.42),0.42)
  sprite.position.y=-8.0+sin(bounce_phase)*1.5
 queue_redraw()

func _draw()->void:
 draw_ellipse(Vector2(0,24),Vector2(68,11),Color(0.18,0.15,0.12,0.22))
 # Small wheel-motion accents keep movement readable at game scale.
 var wobble:=sin(wheel_phase)*1.5
 draw_circle(Vector2(-37,20+wobble),3.0,Color("d6b370"))
 draw_circle(Vector2(36,20+wobble),3.0,Color("d6b370"))

func draw_ellipse(center:Vector2,radius:Vector2,color:Color)->void:
 var points:=PackedVector2Array()
 for i in range(24):
  var a:=TAU*float(i)/24.0
  points.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y))
 draw_colored_polygon(points,color)
