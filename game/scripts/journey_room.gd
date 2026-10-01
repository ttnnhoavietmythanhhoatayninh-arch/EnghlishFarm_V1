extends Node2D

# V4 room layouts follow EnglishFarm_Pixel_Guide_Rooms_V4:
# shared sage wall + wood beam + two windows + checker tiles + warm light from right.
# Only Lily's library uses many bookshelves.
const V4_ROOM_ART={
 "home":"res://game/assets/v4/rooms/01-home-upper.webp",
 "lily":"res://game/assets/v4/rooms/02-library-upper.webp",
 "emma":"res://game/assets/v4/rooms/03-post-office-upper.webp",
 "ben":"res://game/assets/v4/rooms/04-workshop-upper.webp",
 "clara":"res://game/assets/v4/rooms/05-bank-upper.webp",
 "tom":"res://game/assets/v4/rooms/06-garden-shed-upper.webp",
 "noah":"res://game/assets/v4/rooms/07-pier-hut-upper.webp"
}

const ROOMS={
 "home":{
  "title":"Nhà chính","color_main":"d9b995",
  "objects":[
   {"id":"study","label":"Bàn học","rect":Rect2(505,245,265,125),"action":"learn"},
   {"id":"wardrobe","label":"Tủ quần áo","rect":Rect2(855,190,160,250),"action":"shop"}
  ],
  "npc_pos":Vector2.ZERO,"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 },
 "lily":{
  "title":"Thư viện Lily","color_main":"9b815f",
  "objects":[
   {"id":"shelf","label":"Kệ từ vựng","rect":Rect2(205,185,225,245),"action":"vocabulary"},
   {"id":"reading","label":"Bàn đọc","rect":Rect2(500,270,280,120),"action":"reading"},
   {"id":"board","label":"Bảng ABC","rect":Rect2(555,180,170,72),"action":"places"}
  ],
  "npc_pos":Vector2(820,390),"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 },
 "mia":{
  "title":"Chợ của Mia","color_main":"d5ad72",
  "objects":[
   {"id":"order","label":"Quầy đơn hàng","rect":Rect2(435,205,410,105),"action":"mia_order"},
   {"id":"produce","label":"Sạp rau củ","rect":Rect2(220,320,210,145),"action":"shop"},
   {"id":"goods","label":"Kệ vật phẩm","rect":Rect2(850,320,200,145),"action":"shop"}
  ],
  "npc_pos":Vector2(870,270),"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 },
 "emma":{
  "title":"Bưu điện Emma","color_main":"b9c9c7",
  "objects":[
   {"id":"mailbox","label":"Hòm thư","rect":Rect2(220,225,175,220),"action":"writing"},
   {"id":"desk","label":"Bàn viết thư","rect":Rect2(495,275,290,115),"action":"writing_lesson"},
   {"id":"letters","label":"Kệ phân loại thư","rect":Rect2(845,205,190,225),"action":"writing_lesson"}
  ],
  "npc_pos":Vector2(820,390),"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 },
 "ben":{
  "title":"Xưởng của Ben","color_main":"aa835e",
  "objects":[
   {"id":"wood","label":"Gỗ xếp","rect":Rect2(210,215,195,215),"action":"repair"},
   {"id":"bench","label":"Bàn thợ","rect":Rect2(440,280,360,125),"action":"repair"},
   {"id":"tools","label":"Bảng dụng cụ","rect":Rect2(845,190,190,230),"action":"repair"}
  ],
  "npc_pos":Vector2(820,290),"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 },
 "clara":{
  "title":"Ngân hàng Clara","color_main":"728a69",
  "objects":[
   {"id":"lockers","label":"Tủ khóa","rect":Rect2(205,205,220,230),"action":"bank"},
   {"id":"counter","label":"Quầy giao dịch","rect":Rect2(440,270,365,125),"action":"bank"},
   {"id":"safe","label":"Két sắt","rect":Rect2(855,205,175,230),"action":"bank"}
  ],
  "npc_pos":Vector2(815,300),"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 },
 "tom":{
  "title":"Nhà vườn Tom","color_main":"8ea66e",
  "objects":[
   {"id":"seeds","label":"Kệ hạt giống","rect":Rect2(205,215,220,215),"action":"farm"},
   {"id":"table","label":"Bàn làm vườn","rect":Rect2(470,285,310,120),"action":"farm"},
   {"id":"plants","label":"Cây và bao đất","rect":Rect2(835,255,205,185),"action":"farm"}
  ],
  "npc_pos":Vector2(800,260),"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 },
 "noah":{
  "title":"Bến tàu Noah","color_main":"7f9da6",
  "objects":[
   {"id":"rods","label":"Giá cần câu","rect":Rect2(205,215,190,220),"action":"fishing"},
   {"id":"fishbox","label":"Bàn và thùng cá","rect":Rect2(470,305,300,120),"action":"fishing"},
   {"id":"net","label":"Lưới và dụng cụ","rect":Rect2(830,225,210,210),"action":"fishing"}
  ],
  "npc_pos":Vector2(800,300),"floor_rect":Rect2(175,170,930,420),"exit_zone":Rect2(555,540,170,58)
 }
}

var kind:="home"
var upgraded:=false

func room_data(id:String)->Dictionary:
 return ROOMS.get(id,ROOMS.home)

func v4_art_path(id:String)->String:
 return str(V4_ROOM_ART.get(id,""))

func has_v4_art(id:String)->bool:
 var path:=v4_art_path(id)
 return not path.is_empty() and ResourceLoader.exists(path)

func draw_v4_upper(id:String)->bool:
 var path:=v4_art_path(id)
 if path.is_empty() or not ResourceLoader.exists(path):
  return false
 var texture:Texture2D=load(path)
 if texture==null:
  return false
 # Processed V4 layer contains only the upper 1280x380 room area.
 # It intentionally excludes the baked Momo, fake Exit button and fake toolbar.
 draw_texture_rect(texture,Rect2(0,0,1280,380),false)
 return true

func _draw()->void:
 var data:Dictionary=room_data(kind)
 draw_room_shell(Color(data.color_main))
 var used_v4:=draw_v4_upper(kind)
 if not used_v4:
  match kind:
   "home":draw_home()
   "lily":draw_library()
   "mia":draw_market()
   "emma":draw_post()
   "ben":draw_workshop()
   "clara":draw_bank()
   "tom":draw_garden_shed()
   "noah":draw_pier_hut()
 elif kind=="mia":
  draw_market()
 draw_exit(data.exit_zone)

func draw_room_shell(main:Color)->void:
 draw_rect(Rect2(0,0,1280,720),Color("526c5a"))
 # Room frame and pale sage wall.
 draw_rect(Rect2(145,74,990,540),Color("76543d"))
 draw_rect(Rect2(165,96,950,500),Color("b8c7ad"))
 # Thick top wood beam.
 draw_rect(Rect2(180,100,920,44),Color("8e5b38"))
 draw_rect(Rect2(190,108,900,25),Color("ad7445"))
 # Checker tile floor.
 for y in range(170,595,48):
  for x in range(175,1110,48):
   var even:bool=(int(x/48)+int(y/48))%2==0
   var tile:=main.lightened(0.36 if even else 0.25)
   draw_rect(Rect2(x,y,46,46),tile)
   draw_rect(Rect2(x,y,46,46),Color("8d684c"),false,1.2)
 # Left and right side windows.
 draw_window(Rect2(172,150,115,185),false)
 draw_window(Rect2(993,150,115,185),true)
 # Warm sunlight from the right.
 draw_colored_polygon(PackedVector2Array([
  Vector2(1000,190),Vector2(1100,190),Vector2(1040,570),Vector2(780,570)
 ]),Color(1.0,0.83,0.42,0.19))

func draw_window(rect:Rect2,right:bool)->void:
 draw_rect(rect.grow(7),Color("77543c"))
 draw_rect(rect,Color("f5d894"))
 draw_line(Vector2(rect.get_center().x,rect.position.y),Vector2(rect.get_center().x,rect.end.y),Color("9b6945"),5)
 draw_line(Vector2(rect.position.x,rect.get_center().y),Vector2(rect.end.x,rect.get_center().y),Color("9b6945"),5)
 if right:
  draw_circle(rect.end-Vector2(15,10),11,Color("f7e4a7"))

func draw_exit(rect:Rect2)->void:
 # Physical exit zone stays understated; the UI button is drawn separately.
 draw_rect(rect,Color("8d684c"),false,2)

func draw_home()->void:
 # Pink bed at upper left.
 draw_rect(Rect2(260,205,225,205),Color("815c43"))
 draw_rect(Rect2(275,220,195,165),Color("f1d9c3"))
 draw_rect(Rect2(280,275,185,100),Color("dfa0a2"))
 draw_rect(Rect2(305,235,60,40),Color("fff0df"))
 draw_rect(Rect2(370,235,70,40),Color("fff0df"))
 draw_rect(Rect2(330,255,60,34),Color("e8aaa5"))
 # Dining / study table center with two chairs and flower vase.
 draw_rect(Rect2(520,260,250,110),Color("8c613f"))
 draw_rect(Rect2(535,250,220,78),Color("e0bb7e"))
 draw_rect(Rect2(555,252,180,76),Color("f1d7a5"))
 draw_rect(Rect2(490,270,32,92),Color("8d623f"))
 draw_rect(Rect2(770,270,32,92),Color("8d623f"))
 draw_circle(Vector2(645,245),18,Color("f4e6d2"))
 for p in [Vector2(635,228),Vector2(648,220),Vector2(660,230)]:
  draw_circle(p,8,Color("f7f2df"))
 # Wardrobe right.
 draw_rect(Rect2(850,190,165,245),Color("8a5f3e"))
 draw_rect(Rect2(865,210,135,195),Color("b77a47"))
 draw_line(Vector2(932,210),Vector2(932,405),Color("8a5f3e"),5)
 draw_circle(Vector2(918,310),4,Color("4f4338"))
 draw_circle(Vector2(947,310),4,Color("4f4338"))
 # Flowers on both windowsills.
 draw_pot(Vector2(220,338));draw_pot(Vector2(1055,338))
 if upgraded:
  draw_rect(Rect2(465,420,350,28),Color("c78669"))

func draw_library()->void:
 # Tall bookcases on both sides; additional low rear shelves.
 draw_bookcase(Rect2(205,180,220,260),5,8)
 draw_bookcase(Rect2(850,180,220,260),5,8)
 draw_bookcase(Rect2(445,190,125,145),3,5)
 draw_bookcase(Rect2(710,190,125,145),3,5)
 # ABC plaque.
 draw_rect(Rect2(585,175,110,58),Color("76543d"))
 draw_rect(Rect2(595,185,90,38),Color("efe0b2"))
 # Reading desk, open book and brass lamp.
 draw_rect(Rect2(500,300,280,100),Color("684a34"))
 draw_rect(Rect2(515,287,250,75),Color("c99b5f"))
 draw_rect(Rect2(595,305,80,38),Color("eee4c8"))
 draw_line(Vector2(635,305),Vector2(635,343),Color("9b7a52"),2)
 draw_line(Vector2(700,303),Vector2(720,265),Color("ad8a46"),6)
 draw_circle(Vector2(724,258),14,Color("dcb75d"))

func draw_bookcase(rect:Rect2,rows:int,cols:int)->void:
 draw_rect(rect,Color("5e432f"))
 var shelf_h:=rect.size.y/rows
 for r in range(rows):
  draw_rect(Rect2(rect.position+Vector2(8,r*shelf_h+8),Vector2(rect.size.x-16,shelf_h-13)),Color("76543b"))
  var book_w:float=(rect.size.x-28)/cols
  for c in range(cols):
   var colors=[Color("6d8065"),Color("a96545"),Color("c39a52"),Color("52667b")]
   draw_rect(Rect2(rect.position+Vector2(14+c*book_w,r*shelf_h+14),Vector2(book_w-5,shelf_h-27)),colors[(r+c)%colors.size()])

func draw_market()->void:
 # Keep the market as the visual reference room: central counter + produce shelves.
 draw_rect(Rect2(430,210,420,110),Color("674a35"))
 draw_rect(Rect2(445,200,390,76),Color("e0bf83"))
 for x in [220,855]:
  draw_rect(Rect2(x,325,205,145),Color("9a7047"))
  for row in range(2):
   for col in range(3):
    var p:=Vector2(x+38+col*58,350+row*60)
    draw_circle(p,15,Color("d98343") if (row+col)%2==0 else Color("7c9d59"))
 draw_circle(Vector2(870,285),24,Color("d69055"))

func draw_post()->void:
 # Large blue mailbox left.
 draw_rect(Rect2(220,220,165,225),Color("456d9b"))
 draw_rect(Rect2(235,205,135,55),Color("5c88ba"))
 draw_rect(Rect2(250,285,105,18),Color("e8ddc7"))
 draw_rect(Rect2(265,330,75,42),Color("f2e4c9"))
 # Writing desk center.
 draw_rect(Rect2(495,295,290,100),Color("8e6948"))
 draw_rect(Rect2(510,280,260,75),Color("e0c18d"))
 for i in range(3):
  draw_rect(Rect2(545+i*55,295,45,30),Color("f6ecd8"))
 draw_line(Vector2(690,285),Vector2(675,330),Color("4d514f"),5)
 # Mail sorting pigeonholes right.
 draw_rect(Rect2(835,205,205,235),Color("8d6748"))
 for r in range(4):
  for c in range(3):
   var box:=Rect2(850+c*58,220+r*48,48,38)
   draw_rect(box,Color("c69b69"))
   draw_rect(Rect2(box.position+Vector2(8,10),Vector2(32,18)),Color("f2e5ce"))
 # Simple stamp pictures.
 for x in [510,610,710]:
  draw_rect(Rect2(x,180,58,54),Color("f5e8c7"))
  draw_circle(Vector2(x+29,207),12,Color("719a76"))

func draw_workshop()->void:
 # Pale wood stack left.
 draw_rect(Rect2(210,220,205,210),Color("79573d"))
 for y in [235,275,315,355]:
  draw_rect(Rect2(225,y,175,24),Color("c79962"))
 # Central broad workbench.
 draw_rect(Rect2(445,300,360,105),Color("755238"))
 draw_rect(Rect2(460,285,330,75),Color("c49459"))
 # Saw and hammer.
 draw_line(Vector2(555,300),Vector2(610,330),Color("8a9490"),8)
 draw_line(Vector2(625,306),Vector2(670,345),Color("6f553f"),7)
 draw_rect(Rect2(655,330,36,18),Color("89938f"))
 # Tool pegboard right.
 draw_rect(Rect2(835,190,205,235),Color("a86f43"))
 for x in [870,920,970]:
  draw_line(Vector2(x,220),Vector2(x,330),Color("6c6e6a"),7)
 draw_line(Vector2(855,355),Vector2(1015,355),Color("81563a"),8)
 # Pendant lamp.
 draw_line(Vector2(640,145),Vector2(640,205),Color("5f5143"),5)
 draw_circle(Vector2(640,215),18,Color("d8a74f"))

func draw_bank()->void:
 # Lockbox cabinets left.
 draw_rect(Rect2(205,205,220,230),Color("3f654d"))
 for r in range(4):
  for c in range(4):
   var box:=Rect2(220+c*48,220+r*48,40,38)
   draw_rect(box,Color("527a5b"))
   draw_circle(box.get_center(),3,Color("c7a85a"))
 # Teller counter center.
 draw_rect(Rect2(440,275,365,125),Color("4a3d31"))
 draw_rect(Rect2(450,260,345,75),Color("dfc38c"))
 draw_rect(Rect2(525,230,195,42),Color("694f37"))
 # Small coin/card plaque.
 draw_rect(Rect2(610,290,70,34),Color("466551"))
 draw_circle(Vector2(628,307),9,Color("c5a34d"))
 draw_rect(Rect2(644,299,25,16),Color("e3d49d"))
 # Safe right.
 draw_rect(Rect2(855,205,175,230),Color("59695e"))
 draw_rect(Rect2(875,225,135,190),Color("718277"))
 draw_circle(Vector2(943,320),45,Color("c1aa63"))
 draw_circle(Vector2(943,320),25,Color("59695e"))
 for a in range(0,360,45):
  var v:=Vector2.RIGHT.rotated(deg_to_rad(a))*35
  draw_line(Vector2(943,320),Vector2(943,320)+v,Color("d9ca84"),4)

func draw_garden_shed()->void:
 # Seed packets and pots left.
 draw_rect(Rect2(205,210,225,225),Color("76543a"))
 for y in [235,295,355]:
  draw_line(Vector2(220,y),Vector2(415,y),Color("b98652"),8)
  for x in [240,295,350]:
   draw_rect(Rect2(x,y-25,40,30),Color("eee1b6"))
   draw_circle(Vector2(x+20,y-12),8,Color("7aa25e"))
 # Gardening worktable center.
 draw_rect(Rect2(470,310,310,105),Color("77543b"))
 draw_rect(Rect2(485,295,280,75),Color("c18e58"))
 for x in [540,610,680]:
  draw_circle(Vector2(x,300),18,Color("8b684b"))
  draw_circle(Vector2(x,286),18,Color("6f9a5d"))
 # Shovel, rake, watering can on wall.
 draw_line(Vector2(535,195),Vector2(535,285),Color("70513c"),7)
 draw_circle(Vector2(535,290),15,Color("8d9791"))
 draw_line(Vector2(600,195),Vector2(600,285),Color("70513c"),6)
 for x in range(575,626,12):draw_line(Vector2(x,202),Vector2(x,222),Color("8d9791"),3)
 draw_rect(Rect2(675,220,55,42),Color("6f9b73"))
 draw_arc(Vector2(730,245),25,-PI/2,PI/2,16,Color("6f9b73"),5)
 # Sacks and plants right.
 for x in [845,915]:
  draw_rect(Rect2(x,340,62,82),Color("c8ad77"))
  draw_circle(Vector2(x+31,340),30,Color("c8ad77"))
  draw_circle(Vector2(x+31,326),16,Color("6f9c5d"))
 draw_pot(Vector2(1010,405))

func draw_pier_hut()->void:
 # Fishing rod rack left.
 draw_rect(Rect2(205,210,195,225),Color("55473b"))
 for x in [235,275,315,355]:
  draw_line(Vector2(x,225),Vector2(x+15,400),Color("8d6848"),6)
  draw_line(Vector2(x+15,245),Vector2(x+35,265),Color("556f7c"),3)
 # Blue worktable and fish bucket center.
 draw_rect(Rect2(470,320,310,100),Color("4f6f78"))
 draw_rect(Rect2(485,305,280,70),Color("6f9aa5"))
 draw_circle(Vector2(555,305),30,Color("889fa6"))
 draw_arc(Vector2(555,305),18,0,TAU,20,Color("d8e0dc"),5)
 # Net, rope and tackle right.
 draw_arc(Vector2(885,280),68,0,TAU,24,Color("ddd7bf"),6)
 for a in range(0,360,45):
  var v:=Vector2.RIGHT.rotated(deg_to_rad(a))*62
  draw_line(Vector2(885,280),Vector2(885,280)+v,Color("ddd7bf"),2)
 draw_rect(Rect2(845,365,105,55),Color("775842"))
 draw_rect(Rect2(965,345,70,75),Color("8c6745"))
 # Small back doorway showing water, while preserving both side windows.
 draw_rect(Rect2(995,185,95,165),Color("76543d"))
 draw_rect(Rect2(1008,198,69,139),Color("5f9db5"))
 draw_line(Vector2(1010,260),Vector2(1075,260),Color("d4f0ec"),4)
 draw_line(Vector2(1010,290),Vector2(1075,290),Color("d4f0ec"),3)

func draw_pot(pos:Vector2)->void:
 draw_rect(Rect2(pos-Vector2(16,4),Vector2(32,28)),Color("a96d45"))
 draw_circle(pos-Vector2(0,12),18,Color("f3ead3"))
 draw_circle(pos-Vector2(8,22),8,Color("6f995f"))
 draw_circle(pos+Vector2(8,-24),8,Color("6f995f"))
