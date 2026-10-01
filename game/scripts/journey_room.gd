extends Node2D

const ROOMS={
 "home":{
  "title":"Nhà chính",
  "color_main":"d9b995",
  "objects":[
   {"id":"study","label":"Bàn học","rect":Rect2(300,270,190,95),"action":"learn"},
   {"id":"writing","label":"Bàn viết","rect":Rect2(535,255,180,105),"action":"writing"},
   {"id":"wardrobe","label":"Tủ quần áo","rect":Rect2(855,205,125,200),"action":"shop"}
  ],
  "npc_pos":Vector2(0,0),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 },
 "lily":{
  "title":"Thư viện Lily",
  "color_main":"9b815f",
  "objects":[
   {"id":"shelf","label":"Kệ từ vựng","rect":Rect2(220,205,190,210),"action":"vocabulary"},
   {"id":"reading","label":"Bàn đọc","rect":Rect2(515,285,250,100),"action":"reading"},
   {"id":"board","label":"Bảng địa điểm","rect":Rect2(835,205,170,115),"action":"places"}
  ],
  "npc_pos":Vector2(820,390),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 },
 "mia":{
  "title":"Chợ của Mia",
  "color_main":"d5ad72",
  "objects":[
   {"id":"order","label":"Quầy đơn hàng","rect":Rect2(440,205,400,105),"action":"mia_order"},
   {"id":"produce","label":"Sạp hàng","rect":Rect2(230,330,210,145),"action":"shop"},
   {"id":"goods","label":"Kệ vật phẩm","rect":Rect2(850,330,190,145),"action":"shop"}
  ],
  "npc_pos":Vector2(870,270),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 },
 "emma":{
  "title":"Bưu điện Emma",
  "color_main":"b9c9c7",
  "objects":[
   {"id":"mailbox","label":"Hòm thư","rect":Rect2(235,245,155,205),"action":"writing"},
   {"id":"desk","label":"Bàn bài mẫu","rect":Rect2(520,285,250,105),"action":"writing_lesson"},
   {"id":"letters","label":"Kệ thư","rect":Rect2(870,235,150,185),"action":"writing_lesson"}
  ],
  "npc_pos":Vector2(820,390),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 },
 "ben":{
  "title":"Xưởng của Ben",
  "color_main":"aa835e",
  "objects":[
   {"id":"bench","label":"Bàn thợ","rect":Rect2(410,275,350,120),"action":"repair"},
   {"id":"wood","label":"Đống gỗ","rect":Rect2(800,350,205,115),"action":"repair"},
   {"id":"tools","label":"Kệ dụng cụ","rect":Rect2(225,230,150,210),"action":"repair"}
  ],
  "npc_pos":Vector2(820,290),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 },
 "clara":{
  "title":"Ngân hàng Clara",
  "color_main":"728a69",
  "objects":[
   {"id":"counter","label":"Quầy giao dịch","rect":Rect2(380,245,500,120),"action":"bank"},
   {"id":"safe","label":"Két sắt","rect":Rect2(900,225,125,190),"action":"bank"}
  ],
  "npc_pos":Vector2(815,300),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 },
 "tom":{
  "title":"Nhà vườn Tom",
  "color_main":"8ea66e",
  "objects":[
   {"id":"seeds","label":"Kệ hạt giống","rect":Rect2(235,235,180,190),"action":"farm"},
   {"id":"tools","label":"Dụng cụ vườn","rect":Rect2(520,300,220,110),"action":"farm"},
   {"id":"plants","label":"Chậu cây","rect":Rect2(850,315,175,125),"action":"farm"}
  ],
  "npc_pos":Vector2(800,260),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 },
 "noah":{
  "title":"Nhà bến tàu Noah",
  "color_main":"7f9da6",
  "objects":[
   {"id":"rods","label":"Giá cần câu","rect":Rect2(235,230,170,205),"action":"fishing"},
   {"id":"fishbox","label":"Thùng cá","rect":Rect2(500,335,220,105),"action":"fishing"},
   {"id":"net","label":"Lưới đánh cá","rect":Rect2(855,240,170,190),"action":"fishing"}
  ],
  "npc_pos":Vector2(800,300),"floor_rect":Rect2(180,175,920,420),"exit_zone":Rect2(560,555,160,65)
 }
}

var kind:="home"
var upgraded:=false

func room_data(id:String)->Dictionary:
 return ROOMS.get(id,ROOMS.home)

func _draw()->void:
 var data:Dictionary=room_data(kind)
 draw_room_shell(Color(data.color_main))
 match kind:
  "home":draw_home()
  "lily":draw_library()
  "mia":draw_market()
  "emma":draw_post()
  "ben":draw_workshop()
  "clara":draw_bank()
  "tom":draw_garden_shed()
  "noah":draw_pier_hut()
 draw_exit(data.exit_zone)

func draw_room_shell(main:Color)->void:
 draw_rect(Rect2(0,0,1280,720),Color("465b50"))
 draw_rect(Rect2(150,80,980,545),Color("795d47"))
 draw_rect(Rect2(170,100,940,500),Color("b8c4bd"))
 draw_rect(Rect2(170,165,940,435),main.lightened(0.26))
 for y in range(175,590,52):
  for x in range(180,1100,52):
   var light:bool=int(x/52+y/52)%2==0
   draw_rect(Rect2(x,y,50,50),main.lightened(0.38 if light else 0.28))
 draw_rect(Rect2(170,100,940,65),Color("9e8063"))
 draw_rect(Rect2(205,112,150,92),Color("805f45"))
 draw_rect(Rect2(214,120,132,76),Color("f1d79c"))
 draw_line(Vector2(280,120),Vector2(280,196),Color("b48762"),5)
 draw_line(Vector2(214,158),Vector2(346,158),Color("b48762"),5)
 draw_rect(Rect2(925,112,150,92),Color("805f45"))
 draw_rect(Rect2(934,120,132,76),Color("f7dfa6"))
 draw_line(Vector2(1000,120),Vector2(1000,196),Color("b48762"),5)
 draw_line(Vector2(934,158),Vector2(1066,158),Color("b48762"),5)
 # Warm sunlight from the right.
 draw_colored_polygon(PackedVector2Array([Vector2(930,200),Vector2(1070,200),Vector2(1010,540),Vector2(820,540)]),Color(1.0,0.86,0.55,0.14))

func draw_exit(rect:Rect2)->void:
 draw_rect(rect.grow(5),Color("6d5849"))
 draw_rect(rect,Color("c98f68"))
 draw_line(rect.position+Vector2(18,rect.size.y/2),rect.end-Vector2(18,rect.size.y/2),Color("e4c39b"),3)

func draw_home()->void:
 draw_rect(Rect2(275,255,235,105),Color("76553f"))
 draw_rect(Rect2(287,245,210,82),Color("dfc393"))
 draw_rect(Rect2(555,250,175,110),Color("7e5c42"))
 draw_rect(Rect2(565,240,155,82),Color("ecd39f"))
 draw_rect(Rect2(820,220,190,235),Color("825e49"))
 draw_rect(Rect2(840,245,150,185),Color("c89f8e"))
 draw_rect(Rect2(820,455,205,85),Color("d8a9a7"))
 draw_rect(Rect2(835,465,175,58),Color("f3d9cb"))
 draw_circle(Vector2(245,215),18,Color("c87867"))
 draw_line(Vector2(245,215),Vector2(245,195),Color("63845e"),5)
 if upgraded:draw_rect(Rect2(470,440,300,52),Color("b9795c"))

func draw_library()->void:
 for x in [215,850]:
  draw_rect(Rect2(x,205,205,245),Color("674b39"))
  for y in [225,285,345,405]:
   draw_rect(Rect2(x+12,y,180,38),Color("81624a"))
   for i in range(8):
    draw_rect(Rect2(x+18+i*21,y+5,15,29),Color("6c7d68") if i%2==0 else Color("b77e55"))
 draw_rect(Rect2(500,280,270,115),Color("694e3a"))
 draw_rect(Rect2(515,270,240,82),Color("d6b77b"))
 draw_circle(Vector2(640,265),20,Color("d9b35f"))
 draw_rect(Rect2(845,205,185,115),Color("36565b"))
 draw_rect(Rect2(858,218,159,89),Color("435f61"))

func draw_market()->void:
 draw_rect(Rect2(420,215,440,105),Color("6b4e3a"))
 draw_rect(Rect2(435,205,410,75),Color("e0c28f"))
 for x in [225,865]:
  draw_rect(Rect2(x,335,190,140),Color("9a7149"))
  for j in range(3):
   draw_rect(Rect2(x+15+j*55,355,45,45),Color("b97c48"))
   draw_circle(Vector2(x+37+j*55,347),13,Color("df8a45") if j==0 else Color("d6b05a"))
   draw_rect(Rect2(x+15+j*55,407,45,45),Color("b58a58"))
   draw_circle(Vector2(x+37+j*55,424),12,Color("7fa05d"))
 draw_circle(Vector2(878,286),25,Color("d59055"))

func draw_post()->void:
 draw_rect(Rect2(225,245,175,210),Color("7d6b62"))
 draw_rect(Rect2(245,268,135,150),Color("7d9bb5"))
 draw_rect(Rect2(260,295,105,18),Color("f0dfbb"))
 draw_rect(Rect2(505,285,280,110),Color("705340"))
 draw_rect(Rect2(520,275,250,78),Color("e5cfa2"))
 draw_rect(Rect2(855,230,180,215),Color("8c745b"))
 for y in [250,300,350,400]:
  for x in [875,930,985]:
   draw_rect(Rect2(x,y,35,24),Color("f2e3c3"))
   draw_line(Vector2(x,y),Vector2(x+17,y+14),Color("b17e61"),2)

func draw_workshop()->void:
 draw_rect(Rect2(390,285,390,115),Color("76563e"))
 draw_rect(Rect2(405,270,360,78),Color("c39b65"))
 draw_line(Vector2(530,285),Vector2(570,325),Color("6c5a4d"),10)
 draw_rect(Rect2(552,315,45,20),Color("8b9992"))
 draw_rect(Rect2(215,225,170,230),Color("75563f"))
 for y in [245,305,365]:
  draw_line(Vector2(230,y),Vector2(370,y),Color("c39b65"),8)
 draw_rect(Rect2(800,355,210,105),Color("8d633f"))
 for y in range(370,455,22):draw_line(Vector2(815,y),Vector2(995,y-12),Color("b98c59"),10)

func draw_bank()->void:
 draw_rect(Rect2(365,245,530,125),Color("4d5c48"))
 draw_rect(Rect2(380,235,500,85),Color("d0b676"))
 for x in [440,560,680,800]:draw_line(Vector2(x,320),Vector2(x,365),Color("92784f"),8)
 draw_rect(Rect2(895,220,140,205),Color("53645a"))
 draw_circle(Vector2(965,325),45,Color("c5b46e"))
 draw_circle(Vector2(965,325),28,Color("5f715f"))
 draw_line(Vector2(965,298),Vector2(965,352),Color("d8c982"),5)
 draw_line(Vector2(938,325),Vector2(992,325),Color("d8c982"),5)

func draw_garden_shed()->void:
 draw_rect(Rect2(220,235,205,205),Color("76583f"))
 for y in [255,315,375]:
  draw_line(Vector2(235,y),Vector2(410,y),Color("c0935b"),8)
  for x in [255,310,365]:
   draw_rect(Rect2(x,y-18,35,28),Color("b98950"))
 draw_line(Vector2(560,275),Vector2(520,405),Color("76553f"),10)
 draw_circle(Vector2(515,420),26,Color("8aa66e"))
 draw_rect(Rect2(630,330,65,90),Color("7c9d73"))
 draw_circle(Vector2(663,325),25,Color("a9c685"))
 for x in [845,910,975]:
  draw_rect(Rect2(x,375,48,48),Color("9a6848"))
  draw_circle(Vector2(x+24,365),27,Color("6f955e"))

func draw_pier_hut()->void:
 draw_rect(Rect2(215,225,200,230),Color("604c3d"))
 for x in [245,300,355]:
  draw_line(Vector2(x,245),Vector2(x+20,410),Color("a9835b"),7)
 draw_rect(Rect2(490,345,250,100),Color("5f5147"))
 draw_rect(Rect2(510,360,95,65),Color("7894a0"))
 draw_rect(Rect2(615,360,105,65),Color("879fac"))
 draw_arc(Vector2(930,330),75,0,TAU,32,Color("d7ded6"),8)
 for a in range(0,360,45):
  var v:=Vector2.RIGHT.rotated(deg_to_rad(a))*70
  draw_line(Vector2(930,330),Vector2(930,330)+v,Color("d7ded6"),3)
 draw_rect(Rect2(1040,230,45,210),Color("6d5642"))
 draw_rect(Rect2(1030,245,65,180),Color("6f9bab"))
