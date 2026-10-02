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
