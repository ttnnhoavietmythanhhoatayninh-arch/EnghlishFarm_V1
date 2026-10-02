# Mã các hàm Bước 2

Toàn bộ module phòng và các hàm thay đổi trong controller.

## journey_room.gd

```gdscript
extends Node2D
# V4 backgrounds are static. Characters, prompts and toolbar remain runtime nodes.
# Clean 640x300 crops represent source 1920x900 at a uniform 2/3 display scale.
const IMAGE_RECT:=Rect2(0,0,1280,600)
const DEFAULT_WALK_AREA:=Rect2(42,315,1196,275)
const DEFAULT_EXIT:=Rect2(555,535,170,55)
const FOOT_RADIUS:=18.0
const ROOMS={
 "home":{
  "title":"Nhà chính",
  "background":"res://game/assets/v4/rooms/01-home.webp",
  "objects":[
   {"id":"study","label":"Study • Learn","rect":Rect2(475,180,365,160),"action":"learn","approach":Vector2(655,380)},
   {"id":"wardrobe","label":"Wardrobe • Shop","rect":Rect2(880,50,230,275),"action":"shop","approach":Vector2(995,370)}
  ],
  "blockers":[Rect2(120,125,315,280),Rect2(468,175,375,165),Rect2(880,50,230,275)],
  "npc_pos":Vector2.ZERO,
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "lily":{
  "title":"Thư viện Lily",
  "background":"res://game/assets/v4/rooms/02-library.webp",
  "objects":[
   {"id":"shelf","label":"Bookshelf • Vocabulary","rect":Rect2(157,45,205,275),"action":"vocabulary","approach":Vector2(300,365)},
   {"id":"reading","label":"Desk • Reading","rect":Rect2(510,190,265,160),"action":"reading","approach":Vector2(640,395)},
   {"id":"board","label":"Board • Places","rect":Rect2(581,90,117,70),"action":"places","approach":Vector2(815,355)}
  ],
  "blockers":[Rect2(157,45,205,275),Rect2(360,135,157,156),Rect2(510,190,265,160),Rect2(766,135,155,156),Rect2(916,45,205,275)],
  "npc_pos":Vector2(1050,440),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "mia":{
  "title":"Chợ của Mia",
  "background":"res://game/assets/v4/rooms/08-market.png",
  "source_fraction":0.833333333333,
  "objects":[
   {"id":"order","label":"Counter • Orders","rect":Rect2(478,195,322,140),"action":"mia_order","approach":Vector2(640,380)},
   {"id":"produce","label":"Produce • Shop","rect":Rect2(156,76,276,257),"action":"shop","approach":Vector2(300,380)},
   {"id":"goods","label":"Supplies • Shop","rect":Rect2(843,76,266,257),"action":"shop","approach":Vector2(970,380)}
  ],
  "blockers":[Rect2(478,190,322,145),Rect2(156,76,276,257),Rect2(843,76,266,257)],
  "npc_pos":Vector2(1100,450),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "emma":{
  "title":"Bưu điện Emma",
  "background":"res://game/assets/v4/rooms/03-post-office.webp",
  "objects":[
   {"id":"mailbox","label":"Mailbox • Send a letter","rect":Rect2(166,110,154,205),"action":"writing","approach":Vector2(250,360)},
   {"id":"desk","label":"Desk • Writing lesson","rect":Rect2(488,180,307,172),"action":"writing_lesson","approach":Vector2(645,397)},
   {"id":"letters","label":"Letters • Examples","rect":Rect2(868,75,237,246),"action":"writing_lesson","approach":Vector2(965,365)}
  ],
  "blockers":[Rect2(166,110,154,205),Rect2(330,145,92,145),Rect2(488,180,307,172),Rect2(868,75,237,246)],
  "npc_pos":Vector2(1040,445),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "ben":{
  "title":"Xưởng của Ben",
  "background":"res://game/assets/v4/rooms/04-workshop.webp",
  "objects":[
   {"id":"wood","label":"Wood • Repair home","rect":Rect2(156,76,271,255),"action":"repair","approach":Vector2(310,375)},
   {"id":"upgrade","label":"Workbench • Upgrade","rect":Rect2(440,170,370,185),"action":"upgrade","approach":Vector2(625,400)},
   {"id":"tools","label":"Tools • Repair home","rect":Rect2(819,60,255,164),"action":"repair","approach":Vector2(915,375)}
  ],
  "blockers":[Rect2(156,76,271,255),Rect2(440,170,370,185),Rect2(810,248,73,90),Rect2(925,212,200,122)],
  "npc_pos":Vector2(1070,450),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "clara":{
  "title":"Ngân hàng Clara",
  "background":"res://game/assets/v4/rooms/05-bank.png",
  "source_fraction":0.833333333333,
  "objects":[
   {"id":"counter","label":"Counter • Deposit / Withdraw","rect":Rect2(438,210,419,157),"action":"bank","approach":Vector2(640,410)},
   {"id":"safe","label":"Safe • Balance","rect":Rect2(890,72,230,255),"action":"balance","approach":Vector2(985,375)}
  ],
  "blockers":[Rect2(152,72,275,263),Rect2(438,75,419,292),Rect2(890,72,230,255)],
  "npc_pos":Vector2(1075,450),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "tom":{
  "title":"Nhà vườn Tom",
  "background":"res://game/assets/v4/rooms/06-garden-shed.png",
  "source_fraction":0.833333333333,
  "objects":[
   {"id":"seeds","label":"Seeds and pots • Farm","rect":Rect2(155,75,280,256),"action":"farm","approach":Vector2(300,375)},
   {"id":"tools","label":"Tools • Farming guide","rect":Rect2(495,60,300,140),"action":"farm_help","approach":Vector2(650,385)},
   {"id":"plants","label":"Plants • Farm","rect":Rect2(870,135,255,185),"action":"farm","approach":Vector2(975,365)}
  ],
  "blockers":[Rect2(155,75,280,256),Rect2(475,170,348,165),Rect2(870,135,255,185)],
  "npc_pos":Vector2(1070,440),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "noah":{
  "title":"Bến tàu Noah",
  "background":"res://game/assets/v4/rooms/07-pier-hut.webp",
  "objects":[
   {"id":"rods","label":"Fishing rods • Fish","rect":Rect2(173,65,147,235),"action":"fishing","approach":Vector2(280,350)},
   {"id":"reward_box","label":"Crates • Rewards","rect":Rect2(783,235,143,95),"action":"rewards","approach":Vector2(870,380)}
  ],
  "blockers":[Rect2(173,65,147,235),Rect2(322,180,135,132),Rect2(478,180,285,172),Rect2(783,235,143,95)],
  "npc_pos":Vector2(1050,440),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
}

var kind:="home"
var upgraded:=false
var _background_cache:Dictionary={}
var _grids:Dictionary={}

func room_data(id:String=kind)->Dictionary:
 return ROOMS.get(id,ROOMS.home)

func _draw()->void:
 var data:Dictionary=room_data()
 var background:=room_background(data)
 if background!=null:
  var source:=Rect2(Vector2.ZERO,background.get_size())
  source.size.y*=float(data.get("source_fraction",1.0))
  draw_texture_rect_region(background,IMAGE_RECT,source)
  draw_rect(Rect2(0,600,1280,120),Color("526c5a"))
 else:
  draw_runtime_market()

func room_background(data:Dictionary)->Texture2D:
 var path:=str(data.get("background",""))
 if path.is_empty():return null
 if not _background_cache.has(path):_background_cache[path]=load(path)
 return _background_cache[path] as Texture2D

func room_point_walkable(point:Vector2,radius:float=FOOT_RADIUS)->bool:
 if not point.is_finite():return false
 var data:Dictionary=room_data()
 var area:Rect2=data.walk_area
 if not area.grow(-radius).has_point(point):return false
 # Tapered side walls: prevent walking across windows and skirting boards.
 var left:float=lerpf(125.0,42.0,clampf((point.y-315.0)/275.0,0.0,1.0))
 if point.x<left+radius or point.x>1280.0-left-radius:return false
 for raw in data.blockers:
  var blocker:Rect2=raw
  if blocker.grow(radius).has_point(point):return false
 return true

func can_travel(from:Vector2,to:Vector2)->bool:
 var steps:int=maxi(1,ceili(from.distance_to(to)/4.0))
 for i in range(steps+1):
  if not room_point_walkable(from.lerp(to,float(i)/steps)):return false
 return true

func safe_room_point(point:Vector2,radius:float=FOOT_RADIUS)->Vector2:
 if room_point_walkable(point,radius):return point
 var best:=Vector2.INF
 var distance:=INF
 for y in range(335,571,10):
  for x in range(60,1221,10):
   var candidate:=Vector2(x,y)
   var d:float=candidate.distance_squared_to(point)
   if d<distance and room_point_walkable(candidate,radius):
    best=candidate;distance=d
 if best.is_finite():return best
 push_warning("No safe point in room: "+kind)
 return point

func room_grid()->AStarGrid2D:
 if _grids.has(kind):return _grids[kind]
 var grid:=AStarGrid2D.new()
 grid.region=Rect2i(0,0,65,31)
 grid.cell_size=Vector2(20,20)
 grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
 grid.update()
 for y in range(31):
  for x in range(65):grid.set_point_solid(Vector2i(x,y),not room_point_walkable(Vector2(x*20,y*20)))
 _grids[kind]=grid
 return grid

func closest_grid_point(point:Vector2,grid:AStarGrid2D)->Vector2i:
 var best:=Vector2i(-1,-1)
 var distance:=INF
 for y in range(16,29):
  for x in range(3,62):
   var id:=Vector2i(x,y)
   var pos:=Vector2(id)*20.0
   var d:float=point.distance_squared_to(pos)
   if d<distance and not grid.is_point_solid(id) and can_travel(point,pos):best=id;distance=d
 return best

func find_room_path(from:Vector2,to:Vector2)->PackedVector2Array:
 var goal:=safe_room_point(to)
 if can_travel(from,goal):return PackedVector2Array([goal])
 var grid:=room_grid()
 var start:=closest_grid_point(from,grid)
 var end:=closest_grid_point(goal,grid)
 if start.x<0 or end.x<0:return PackedVector2Array()
 var raw:PackedVector2Array=grid.get_point_path(start,end)
 if raw.is_empty():return raw
 raw.append(goal)
 # Validate every segment, including the connection from the actual position.
 var previous:=from
 for point in raw:
  if not can_travel(previous,point):return PackedVector2Array()
  previous=point
 return raw

func interaction_at(point:Vector2)->Dictionary:
 var best:Dictionary={}
 var distance:=55.0
 for obj in room_data().objects:
  var approach:Vector2=obj.approach
  var d:float=point.distance_to(approach)
  if d<distance and can_travel(point,approach):best=obj;distance=d
 return best

func draw_runtime_market()->void:
 # Mia has no supplied room PNG. Keep a V4-style runtime market while preserving
 # the same fixed-background/dynamic-character architecture as the other rooms.
 draw_rect(Rect2(0,0,1280,720),Color("526c5a"))
 draw_rect(Rect2(50,55,1180,525),Color("76543d"))
 draw_rect(Rect2(65,70,1150,495),Color("b8c7ad"))
 for y in range(320,570,48):
  for x in range(72,1210,48):
   var tile_index:int=int(x/48)+int(y/48)
   draw_rect(Rect2(x,y,46,46),Color("d9c697") if tile_index%2==0 else Color("c3aa7d"))
 draw_rect(Rect2(430,205,420,125),Color("6b4b34"))
 draw_rect(Rect2(445,195,390,78),Color("e0bf83"))
 for shelf_x in [205,845]:
  draw_rect(Rect2(shelf_x,315,225,160),Color("9a7047"))
  for row in range(2):
   for col in range(3):
    var p:=Vector2(shelf_x+40+col*62,345+row*62)
    draw_circle(p,17,Color("d98343") if (row+col)%2==0 else Color("7c9d59"))
 # Warm sunlight from the right, matching the seven supplied V4 rooms.
 draw_colored_polygon(PackedVector2Array([
  Vector2(1080,100),Vector2(1215,100),Vector2(1120,565),Vector2(850,565)
 ]),Color(1.0,0.83,0.42,0.16))

func draw_exit(rect:Rect2)->void:
 draw_rect(rect,Color("8d684c"),false,2)
```

## open_dialog

```gdscript
func open_dialog(id:String,title:String)->void:
 if not state.difficulty_chosen and id!="difficulty":return
 screen=id;fishing_running=false;player.stop();pending_npc="";pending_door=""
 room_has_target=false;room_route.clear();room_pending_action=""
 for c in body.get_children():body.remove_child(c);c.queue_free()
 title_label.text=title;feedback.text="";feedback.modulate=Color.WHITE;close_button.disabled=false
 dialog.show()
 fit_dialog_layout()
```

## _unhandled_input

```gdscript
func _unhandled_input(event:InputEvent)->void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE:
   if dialog.visible:close_dialog()
   elif interior.visible:leave_room()
   return
  var focus:=get_viewport().gui_get_focus_owner()
  if focus is LineEdit or focus is TextEdit:return
  if event.keycode==KEY_F1:show_guide(0);return
  if event.keycode==KEY_M:
   toggle_map()
   return
  if event.keycode==KEY_E and not dialog.visible:
   if interior.visible:
    room_interact()
   else:
    var n:=nearest_npc()
    if not n.is_empty():interact_npc(n.id)
   return
 if interior.visible and not dialog.visible:
  if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
   var point:Vector2=event.position
   var data:Dictionary=interior.room_data(current_room)
   if Rect2(data.exit_zone).has_point(point):
    leave_room()
    return
   if room_npc!=null and point.distance_to(room_npc.position-Vector2(0,35))<55:
    set_room_target(room_npc.position+Vector2(-65,0),"talk")
    return
   for obj in data.objects:
    if Rect2(obj.rect).has_point(point):
     set_room_target(obj.approach,str(obj.action))
     return
   if Rect2(data.floor_rect).has_point(point):set_room_target(point)
  return
 if not state.onboarded or dialog.visible or state.delivery_active:return
 if event is InputEventMouseButton and event.pressed:
  if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
   var camera:Camera2D=player.get_node("Camera2D");camera.zoom=Vector2.ONE*clampf(camera.zoom.x+(0.1 if event.button_index==MOUSE_BUTTON_WHEEL_UP else -0.1),0.6,1.4)
  elif event.button_index==MOUSE_BUTTON_LEFT:
   var target:=get_global_mouse_position()
   for n in npc_data:
    if state.level<n.level:continue
    if target.distance_to(n.at*2)<90:pending_npc=n.id;player.walk_to(n.at*2);return
    if target.distance_to(n.door*2)<85 and nav.allowed(n.door*2):pending_door=n.id;player.walk_to(n.door*2);return
   if nav.allowed(target):player.walk_to(target)
   else:notify("Khu vực chưa mở. Xem Tasks để lên cấp.")
```

## enter_room

```gdscript
func enter_room(id:String)->void:
 pending_npc=""
 pending_door=""
 if interior.visible and current_room==id:return
 var n:=npc_by_id(id)
 if n.is_empty() or state.level<n.level:return
 if id=="lily" and state.level<2:
  notify("Thư viện mở cấp 2. Lily đang đến nông trại dạy bạn.")
  return
 close_dialog()
 player.stop()
 world_player_position=player.global_position
 current_room=id
 interior.kind=id
 interior.upgraded=state.house_level>1
 interior.queue_redraw()
 interior.show()
 room_ui.show()
 room_has_target=false
 map_panel.hide()
 hint.hide()
 layout_room_toolbar(true)
 for c in room_ui.get_children():
  if c!=room_hint:c.queue_free()
 room_hint.show()
 var data:Dictionary=interior.room_data(id)
 var leave:=make_button(room_ui,"Ra ngoài (Esc)",leave_room,50)
 leave.position=Vector2(535,540)
 leave.custom_minimum_size=Vector2(210,50)
 leave.size=Vector2(210,50)
 if player.get_parent()!=room_layer:
  player.reparent(room_layer)
 var camera:Camera2D=player.get_node("Camera2D")
 camera.enabled=false
 player.set_physics_process(false)
 room_route.clear();room_pending_action=""
 player.position=interior.safe_room_point(Vector2(640,480),18.0)
 player.show()
 spawn_room_npc(id)
 tip_once("room","Nhấn Esc để ra ngoài.")
 update_room_hint()
```

## leave_room

```gdscript
func leave_room()->void:
 var room_id:=current_room
 var n:=npc_by_id(room_id)
 clear_room_npc()
 interior.hide()
 room_ui.hide()
 dialog.hide()
 screen=""
 current_room=""
 pending_npc=""
 pending_door=""
 fishing_running=false
 room_has_target=false
 if player.get_parent()!=self:
  player.reparent(self)
 var camera:Camera2D=player.get_node("Camera2D")
 camera.enabled=true
 player.stop()
 if not n.is_empty():
  var requested_exit:Vector2=n.door*2+Vector2(0,110)
  var exit_pt:Vector2=safe_walkable_near(requested_exit)
  if not nav.allowed(exit_pt) or not nav.is_walkable(exit_pt,12.0) or not has_walkable_step(exit_pt):
   exit_pt=safe_walkable_near(n.at*2)
  if not nav.allowed(exit_pt) or not nav.is_walkable(exit_pt,12.0) or not has_walkable_step(exit_pt):
   exit_pt=safe_walkable_near(Vector2(200,690)*2)
  player.global_position=exit_pt
 world_player_position=player.global_position
 player.locked=not state.onboarded or state.delivery_active
 player.set_physics_process(true)
 room_route.clear();room_pending_action=""
 hint.show()
 layout_room_toolbar(false)
 get_viewport().gui_release_focus()
```

## layout_room_toolbar

```gdscript
func layout_room_toolbar(inside:bool)->void:
 var index:=0
 for b in command_buttons:
  b.visible=not inside or b.text!="Learn"
  if not b.visible:continue
  b.position=Vector2(100+index*180,620) if inside else Vector2(18+index*110,610)
  b.size=Vector2(170,78) if inside else Vector2(100,72)
  index+=1
```

## set_room_target

```gdscript
func set_room_target(point:Vector2,action:String="")->void:
 room_pending_action=action
 room_target=interior.safe_room_point(point)
 room_route=interior.find_room_path(player.position,room_target)
 room_has_target=not room_route.is_empty()
 if not room_has_target:room_pending_action="";notify("No clear path. Try another spot.")
```

## process_room_movement

```gdscript
func process_room_movement(delta:float)->void:
 if current_room.is_empty() or dialog.visible:return
 var previous:Vector2=player.position
 var move:Vector2=Input.get_vector("move_left","move_right","move_up","move_down")
 var budget:=260.0*minf(delta,0.05)
 if move.length_squared()>0.01:
  room_has_target=false;room_route.clear();room_pending_action=""
  var motion:=move.normalized()*budget
  for axis in [Vector2(motion.x,0),Vector2(0,motion.y)]:
   var target:Vector2=player.position+axis
   if interior.can_travel(player.position,target):player.position=target
 elif room_has_target:
  if room_route.is_empty():room_route=interior.find_room_path(player.position,room_target)
  while budget>0.0 and not room_route.is_empty():
   var next:Vector2=room_route[0]
   var distance:float=player.position.distance_to(next)
   var step:float=minf(budget,distance)
   var target:Vector2=player.position.move_toward(next,step)
   if not interior.can_travel(player.position,target):
    room_route.clear();room_pending_action="";break
   player.position=target;budget-=step
   if distance<=step+0.01:room_route.remove_at(0)
  if room_route.is_empty():
   room_has_target=false
   var action:=room_pending_action;room_pending_action=""
   if not action.is_empty():
    if action=="talk":interact_npc(current_room)
    else:room_action(action)
 var motion:Vector2=player.position-previous
 if motion.length_squared()>0.01:
  player.direction=("right" if motion.x>0 else "left") if absf(motion.x)>absf(motion.y) else ("down" if motion.y>0 else "up")
  player.visual.play("walk_"+player.direction)
 else:player.visual.play("idle_"+player.direction)
 update_room_hint()
```

## clear_room_npc

```gdscript
func clear_room_npc()->void:
 if room_npc!=null and is_instance_valid(room_npc):
  room_npc.hide()
  room_npc.queue_free()
 room_npc=null
```

## spawn_room_npc

```gdscript
func spawn_room_npc(id:String)->void:
 clear_room_npc()
 if id=="home":return
 var n:=npc_by_id(id)
 if n.is_empty():return
 var data:Dictionary=interior.room_data(id)
 room_npc=Node2D.new()
 room_npc.position=interior.safe_room_point(data.get("npc_pos",Vector2(1030,455)))
 room_npc.z_index=int(room_npc.position.y)
 var sprite=art.animated("npcs",{"idle":[int(n.sprite),int(n.sprite)+3]},62.0)
 sprite.play("idle")
 room_npc.add_child(sprite)
 var label:=Label.new()
 label.text=str(n.name)+" • "+str(n.role)
 label.position=Vector2(-115,-100)
 label.size=Vector2(230,30)
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.add_theme_font_size_override("font_size",16)
 label.add_theme_color_override("font_color",Color("342b24"))
 label.add_theme_stylebox_override("normal",Style.box("f9edcd","738b53",8))
 room_npc.add_child(label)
 room_layer.add_child(room_npc)
```

## nearest_room_object

```gdscript
func nearest_room_object()->Dictionary:
 if current_room.is_empty():return {}
 return interior.interaction_at(player.position)
```

## near_room_npc

```gdscript
func near_room_npc()->bool:
 return room_npc!=null and player.position.distance_to(room_npc.position)<85.0
```

## update_room_hint

```gdscript
func update_room_hint()->void:
 if not interior.visible:return
 var data:Dictionary=interior.room_data(current_room)
 if Rect2(data.exit_zone).grow(35).has_point(player.position):
  room_hint.text="[E] Ra ngoài"
  return
 var obj:=nearest_room_object()
 if not obj.is_empty():room_hint.text="[E] "+str(obj.label)
 elif near_room_npc():room_hint.text="[E] Talk to "+str(npc_by_id(current_room).name)
 else:room_hint.text="Move: WASD / arrows / click • Interact: E"
```

## room_interact

```gdscript
func room_interact()->void:
 if current_room.is_empty():return
 var data:Dictionary=interior.room_data(current_room)
 if Rect2(data.exit_zone).grow(35).has_point(player.position):
  leave_room()
  return
 var obj:=nearest_room_object()
 if not obj.is_empty():room_action(str(obj.action))
 elif near_room_npc():interact_npc(current_room)
```

## room_action

```gdscript
func room_action(action:String)->void:
 room_has_target=false
 room_route.clear();room_pending_action=""
 match action:
  "learn":open_learning()
  "writing":show_writing()
  "shop":show_shop()
  "vocabulary":show_vocabulary(0)
  "reading":show_reading()
  "places":show_places()
  "mia_order":interact_npc("mia")
  "writing_lesson":show_writing_lesson()
  "repair":show_workshop()
  "upgrade":show_workshop()
  "bank":show_bank()
  "balance":show_balance()
  "farm":show_farm()
  "farm_help":show_farm_help()
  "fishing":show_fishing()
  "rewards":show_rewards()
```

## show_balance

```gdscript
func show_balance()->void:
 if state.level<3:
  notify("Ngân hàng mở ở cấp 3.")
  return
 open_dialog("balance","Két sắt Clara • Số dư")
 line("Ví: %d cards"%state.cards,24)
 line("Tiết kiệm: %d cards"%state.bank_balance,24)
 line("Đây là Word Cards trong game, không phải tiền thật.",16)
 make_button(body,"Gửi / Rút tại quầy",show_bank)
```

## show_farm_help

```gdscript
func show_farm_help()->void:
 open_dialog("farm_help","Nhà vườn Tom • Hướng dẫn")
 line("1. Gieo (Plant): cần có hạt và một ô đất trống.",18)
 line("2. Tưới (Water): tưới sau khi gieo để cây tiếp tục phát triển.",18)
 line("3. Thu hoạch (Harvest): khi cây sẵn sàng, nhận cà rốt và Cards.",18)
 line("Học bài Reading để nhận hạt lần đầu; có thể mua thêm hạt sau khi đã mở loại hạt.",16)
 make_button(body,"Mở Farm",show_farm)
```

## show_rewards

```gdscript
func show_rewards()->void:
 if state.level<3:
  notify("Bến câu mở ở cấp 3.")
  return
 open_dialog("rewards","Thùng thưởng Noah")
 line("Cá đã bắt: %d"%state.fish,24)
 line("Cards hiện có: %d"%state.cards,22)
 line("Powers hiện có: %d"%state.powers,22)
 line("Câu đúng trong vùng 40–70 nhận 1 cá và +3 Cards; phần thưởng câu cá tính tối đa một lần/ngày.",16)
 make_button(body,"Đi câu cá",show_fishing)
```
