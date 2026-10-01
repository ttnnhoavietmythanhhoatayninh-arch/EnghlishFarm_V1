extends Control
var game:Node2D
func _draw()->void:
 if game==null:return
 draw_texture_rect(game.current_texture(),Rect2(Vector2.ZERO,size),false)
 var scale2:=size/Vector2(3072,2048)
 for r in game.locked_regions():draw_rect(Rect2(r.position*scale2,r.size*scale2),Color("718b73"))
 for npc in game.npc_data:
  if game.state.level>=npc.level:draw_circle(npc.at*2*scale2,3,Color("eabf64"))
 draw_circle(game.player.position*scale2,4,Color("d8743a"))
