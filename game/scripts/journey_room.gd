extends Node2D

# EnglishFarm Journey V4 room runtime.
# The seven supplied V4 room illustrations are fixed backgrounds. Momo, NPCs,
# interaction prompts and the bottom toolbar are runtime nodes layered above them.
const IMAGE_RECT:=Rect2(0,0,1280,600)
const DEFAULT_WALK_AREA:=Rect2(42,315,1196,260)
const DEFAULT_EXIT:=Rect2(555,520,170,68)

const ROOMS={
 "home":{
  "title":"Nhà chính",
  "background":"res://game/assets/v4/rooms/01-home.webp",
  "objects":[
   {"id":"study","label":"Bàn học • Learn","rect":Rect2(485,188,360,180),"action":"learn"},
   {"id":"wardrobe","label":"Tủ • Cửa hàng","rect":Rect2(910,105,235,255),"action":"shop"}
  ],
  "blockers":[Rect2(72,145,355,235),Rect2(470,165,390,205),Rect2(900,90,255,285)],
  "npc_pos":Vector2.ZERO,
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "lily":{
  "title":"Thư viện Lily",
  "background":"res://game/assets/v4/rooms/02-library.webp",
  "objects":[
   {"id":"shelf","label":"Kệ • Từ vựng","rect":Rect2(120,100,265,220),"action":"vocabulary"},
   {"id":"reading","label":"Bàn • Đọc","rect":Rect2(460,195,420,190),"action":"reading"},
   {"id":"board","label":"Bảng • Địa điểm","rect":Rect2(550,88,185,90),"action":"places"}
  ],
  "blockers":[Rect2(115,80,275,230),Rect2(430,165,450,230),Rect2(895,80,270,230)],
  "npc_pos":Vector2(1030,455),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "mia":{
  "title":"Chợ của Mia","color_main":"d5ad72",
  "objects":[
   {"id":"order","label":"Quầy • Đơn hàng","rect":Rect2(430,210,420,120),"action":"mia_order"},
   {"id":"produce","label":"Sạp rau củ • Cửa hàng","rect":Rect2(205,315,230,155),"action":"shop"},
   {"id":"goods","label":"Kệ vật phẩm • Cửa hàng","rect":Rect2(845,315,225,155),"action":"shop"}
  ],
  "blockers":[Rect2(415,190,450,160),Rect2(190,295,260,190),Rect2(830,295,255,190)],
  "npc_pos":Vector2(1020,445),
  "walk_area":Rect2(120,330,1040,245),"floor_rect":Rect2(120,330,1040,245),"exit_zone":DEFAULT_EXIT
 },
 "emma":{
  "title":"Bưu điện Emma",
  "background":"res://game/assets/v4/rooms/03-post-office.webp",
  "objects":[
   {"id":"mailbox","label":"Hòm thư • Gửi thư","rect":Rect2(85,125,165,235),"action":"writing"},
   {"id":"desk","label":"Bàn • Bài mẫu","rect":Rect2(365,155,350,205),"action":"writing_lesson"}
  ],
  "blockers":[Rect2(72,115,190,250),Rect2(345,140,390,225),Rect2(790,92,270,275)],
  "npc_pos":Vector2(1050,450),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "ben":{
  "title":"Xưởng của Ben",
  "background":"res://game/assets/v4/rooms/04-workshop.webp",
  "objects":[
   {"id":"wood","label":"Gỗ + dụng cụ • Sửa nhà","rect":Rect2(95,110,310,245),"action":"repair"},
   {"id":"upgrade","label":"Bàn thợ • Nâng cấp","rect":Rect2(455,160,430,215),"action":"upgrade"}
  ],
  "blockers":[Rect2(85,95,330,270),Rect2(445,145,450,240),Rect2(920,95,245,250)],
  "npc_pos":Vector2(1045,455),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "clara":{
  "title":"Ngân hàng Clara",
  "background":"res://game/assets/v4/rooms/05-bank.webp",
  "objects":[
   {"id":"counter","label":"Quầy • Gửi/Rút","rect":Rect2(350,125,485,235),"action":"bank"},
   {"id":"safe","label":"Két sắt • Xem số dư","rect":Rect2(900,115,245,240),"action":"balance"}
  ],
  "blockers":[Rect2(65,110,270,235),Rect2(345,110,500,255),Rect2(895,105,255,255)],
  "npc_pos":Vector2(1050,455),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "tom":{
  "title":"Nhà vườn Tom",
  "background":"res://game/assets/v4/rooms/06-garden-shed.webp",
  "objects":[
   {"id":"seeds","label":"Hạt + chậu • Mở Farm","rect":Rect2(80,105,310,250),"action":"farm"},
   {"id":"tools","label":"Dụng cụ • Hướng dẫn","rect":Rect2(460,145,415,220),"action":"farm_help"}
  ],
  "blockers":[Rect2(75,95,325,270),Rect2(450,140,435,235),Rect2(900,120,255,235)],
  "npc_pos":Vector2(1040,455),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 },
 "noah":{
  "title":"Bến tàu Noah",
  "background":"res://game/assets/v4/rooms/07-pier-hut.webp",
  "objects":[
   {"id":"rods","label":"Cần câu • Câu cá","rect":Rect2(95,105,300,250),"action":"fishing"},
   {"id":"reward_box","label":"Thùng • Xem thưởng","rect":Rect2(865,300,235,150),"action":"rewards"}
  ],
  "blockers":[Rect2(90,95,315,270),Rect2(445,145,440,245),Rect2(850,155,265,210)],
  "npc_pos":Vector2(1050,455),
  "walk_area":DEFAULT_WALK_AREA,"floor_rect":DEFAULT_WALK_AREA,"exit_zone":DEFAULT_EXIT
 }
}

var kind:="home"
var upgraded:=false
var _background_cache:Dictionary={}

func room_data(id:String=kind)->Dictionary:
 return ROOMS.get(id,ROOMS.home)

func _draw()->void:
 var data:Dictionary=room_data(kind)
 var background:=room_background(data)
 if background!=null:
  # Runtime texture is a cleaned V4 image: no baked Momo/NPC, leave button or toolbar.
  draw_texture_rect(background,IMAGE_RECT,false)
  draw_rect(Rect2(0,600,1280,120),Color("526c5a"))
  return
 draw_runtime_market()
 draw_exit(Rect2(data.exit_zone))

func room_background(data:Dictionary)->Texture2D:
 var path:=str(data.get("background",""))
 if path.is_empty() or not ResourceLoader.exists(path):
  return null
 if not _background_cache.has(path):
  _background_cache[path]=load(path)
 return _background_cache[path] as Texture2D

func room_point_walkable(point:Vector2,radius:float=18.0)->bool:
 var data:Dictionary=room_data(kind)
 var walk_area:Rect2=data.get("walk_area",data.get("floor_rect",DEFAULT_WALK_AREA))
 var safe_area:=walk_area.grow(-radius)
 if safe_area.size.x<=0.0 or safe_area.size.y<=0.0 or not safe_area.has_point(point):
  return false
 for raw in data.get("blockers",[]):
  var blocker:Rect2=raw
  if blocker.grow(radius).has_point(point):
   return false
 return true

func safe_room_point(point:Vector2,radius:float=18.0)->Vector2:
 if room_point_walkable(point,radius):
  return point
 var data:Dictionary=room_data(kind)
 var walk_area:Rect2=data.get("walk_area",data.get("floor_rect",DEFAULT_WALK_AREA))
 var safe_area:=walk_area.grow(-radius)
 var anchor:=Vector2(
  clampf(point.x,safe_area.position.x,safe_area.end.x),
  clampf(point.y,safe_area.position.y,safe_area.end.y)
 )
 if room_point_walkable(anchor,radius):
  return anchor
 var directions=[
  Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,
  Vector2(1,1).normalized(),Vector2(-1,1).normalized(),
  Vector2(1,-1).normalized(),Vector2(-1,-1).normalized()
 ]
 for distance in [8.0,16.0,24.0,40.0,64.0,96.0,128.0,180.0,240.0]:
  for direction in directions:
   var candidate:=anchor+direction*distance
   if room_point_walkable(candidate,radius):
    return candidate
 var fallback:=Vector2(640,500)
 if room_point_walkable(fallback,radius):
  return fallback
 push_warning("Không tìm thấy điểm đi an toàn trong phòng %s gần %s"%[kind,point])
 return point

func draw_runtime_market()->void:
 # Mia has no supplied room PNG. Keep a V4-style runtime market while preserving
 # the same fixed-background/dynamic-character architecture as the other rooms.
 draw_rect(Rect2(0,0,1280,720),Color("526c5a"))
 draw_rect(Rect2(50,55,1180,525),Color("76543d"))
 draw_rect(Rect2(65,70,1150,495),Color("b8c7ad"))
 for y in range(320,570,48):
  for x in range(72,1210,48):
   var light:=((x/48)+(y/48)) as int
   draw_rect(Rect2(x,y,46,46),Color("d9c697") if light%2==0 else Color("c3aa7d"))
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
