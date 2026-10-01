extends Node2D
const State=preload("res://game/scripts/journey_state.gd")
const Art=preload("res://game/scripts/art.gd")
const Nav=preload("res://game/scripts/journey_navigation.gd")
const Style=preload("res://game/scripts/journey_theme.gd")
const Mini=preload("res://game/scripts/journey_map.gd")
const Room=preload("res://game/scripts/journey_room.gd")
const GUIDE_PAGES=[
 ["Cho Momo đi và trò chuyện","1. Đi đến một chỗ: Nhấp chuột trái vào mặt đất.\n\n2. Đi bằng bàn phím: Dùng W A S D hoặc các phím mũi tên.\n\n3. Trò chuyện và vào nhà: Nhấp nhân vật để nói chuyện. Nhấp biển cửa để vào.\n\nĐứng gần nhân vật và nhấn E cũng mở trò chuyện. Esc hoặc × để đóng."],
 ["Học trước, làm bài sau","1. Mở Learn: Chọn mục Từ vựng để học 3 từ.\n\n2. Xem từng thẻ từ: Đọc nghĩa tiếng Việt và câu ví dụ.\n\n3. Làm bài kiểm tra: Chọn đáp án. Chưa đúng thì xem lại và thử tiếp.\n\nNút đọc từ chỉ phát tiếng nếu máy có giọng đọc tiếng Anh."],
 ["Làm bài đọc để nhận hạt","1. Chọn Reading trong Learn: Xem cách đọc và đoạn văn mẫu.\n\n2. Trả lời 3 câu hỏi: Gõ câu trả lời ngắn, rồi bấm Kiểm tra.\n\n3. Nhận 3 hạt giống: Trả lời đúng cả 3 câu để nhận hạt lần đầu.\n\nMỗi mức học nhận hạt từ bài đọc một lần. Có thể mua thêm sau khi mở hạt."],
 ["Gieo hạt → Tưới → Thu hoạch","1. Plant = Gieo hạt: Chọn ô đất trống, bấm Plant.\n\n2. Water = Tưới cây: Bấm Water ở ô vừa gieo.\n\n3. Harvest = Thu hoạch: Khi cây sẵn sàng, bấm Harvest.\n\nChế độ nhanh: cây lớn sau 20 giây; héo nếu quá 60 giây không tưới."],
 ["Cấp 1 có 3 việc cần làm","1. Học và nhớ 3 từ: Hoàn thành bài kiểm tra từ vựng.\n\n2. Làm xong bài đọc: Trả lời đúng 3 câu để mở hạt giống.\n\n3. Thu hoạch 3 củ cà rốt: Chăm cây và thu hoạch ở khu vườn.\n\nMỗi việc làm đầy 1/3 thanh cấp. Đủ 3 việc: lên cấp và nhận 1 Power."],
 ["Hiểu thẻ thưởng và gợi ý","1. Học từ để nhận Cards: Đúng một từ lần đầu: nhận 1 thẻ.\n\n2. Chăm vườn cũng có thưởng: Mỗi củ cà rốt thu hoạch: nhận thêm 2 thẻ.\n\n3. Dùng Power khi cần: Bấm Gợi ý trong bài kiểm tra, dùng 1 Power.\n\nCards và Powers là phần thưởng trong game. Không phải tiền thật."],
 ["Cấp 2: Giao hàng và gửi thư","1. Nhận đơn của Mia: Chuẩn bị đủ 3 củ cà rốt.\n\n2. Chất hàng lên xe: Chờ xe đến chợ rồi mới nhận thưởng.\n\n3. Mở Letters để viết thư: Học mẫu, viết ít nhất 10 từ, tự kiểm rồi gửi Emma.\n\nThư luyện tập lưu trên máy. Game xác nhận gửi, chưa chấm chất lượng tiếng Anh."],
 ["Khám phá từng nơi trong thị trấn","1. Cấp 1 · Bắt đầu ở nông trại: Lily dạy học, Tom hướng dẫn chăm vườn.\n\n2. Cấp 2 · Mở thêm địa điểm: Vào thư viện, chợ Mia và bưu điện Emma.\n\n3. Cấp 3 · Khám phá tiếp: Ben sửa nhà, Clara giữ thẻ, Noah dạy câu cá.\n\nCấp 4 mở vườn cây và vật phẩm mới. Vùng phủ xanh là nơi chưa mở."],
 ["Cần hỗ trợ? Các nút ở đây","1. ? Help hoặc F1: Mở lại toàn bộ hướng dẫn.\n\n2. Settings = Cài đặt: Đổi độ khó, cỡ chữ và thời gian cây lớn.\n\n3. Map = Bản đồ: Xem vị trí Momo và các nơi trong thị trấn.\n\nMuốn đổi thời gian cây, hãy thu hoạch hoặc dọn hết cây trước. Tiến trình tự lưu."]
]
const SAVE="user://englishfarm_journey_v3.json"
var save_path:=SAVE # Tests inject a separate path; production retains the V3 file.
const TASK_NAMES={"vocabulary":"Học và nhớ 3 từ","reading":"Học cách đọc, mở 3 hạt","harvest":"Thu hoạch 3 củ cà rốt","delivery":"Giao hàng cho Mia","grammar":"Học và làm ngữ pháp","letter":"Học viết và gửi thư","house":"Nâng cấp căn nhà","fishing":"Câu được một con cá","bank":"Gửi thẻ vào ngân hàng","orchard":"Mở vườn cây ăn quả","outfit":"Mua trang phục","power":"Mua thêm một Power"}
var state=State.new()
var art:RefCounted
var nav:RefCounted
var curriculum:Dictionary
var lessons:Dictionary
var world:Texture2D
var starter:Texture2D
var screen:=""
var persistence_enabled:=true
var dialog:PanelContainer
var body:VBoxContainer
var title_label:Label
var close_button:Button
var feedback:Label
var hud:Label
var bar:ProgressBar
var map_panel:PanelContainer
var minimap:Control
var hint:Label
var toast:Label
var toast_timer:=0.0
var ui:Control
var layer:CanvasLayer
var interior:Node2D
var room_layer:CanvasLayer
var room_ui:Control
var room_hint:Label
var room_target:=Vector2.ZERO
var room_has_target:=false
var command_buttons:Array[Button]=[]
var current_room:=""
var world_player_position:=Vector2.ZERO
var writing:TextEdit
var quiz_kind:=""
var quiz_index:=0
var quiz_answers:Array=[]
var quiz_input:LineEdit
var seen_words:Dictionary={}
var guide_index:=0
var pending_npc:=""
var pending_door:=""
var npc_data:Array=[]
var npc_nodes:Dictionary={}
var door_nodes:Dictionary={}
var crop_nodes:Array=[]
var crop_stages:Array=[]
var truck:Node2D
var truck_route:=PackedVector2Array()
var fishing_slider:ProgressBar
var fishing_running:=false
var fishing_elapsed:=0.0
var fishing_position:=0.0
var quest_level:=1
var elapsed:=0.0
var refresh_clock:=0.0
@onready var player=$Momo
func now()->int:return int(Time.get_unix_time_from_system())
func crop_time()->int:return int(Time.get_unix_time_from_system()*2160) if state.demo_mode else now()
func _ready()->void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 art=Art.new();nav=Nav.new()
 world=load("res://game/assets/town.png");starter=load("res://game/assets/town_starter.png")
 curriculum=JSON.parse_string(FileAccess.get_file_as_string("res://data/curriculum_v3.json"))
 lessons=JSON.parse_string(FileAccess.get_file_as_string("res://data/learning_v1.json"))
 if persistence_enabled:state.load_from(save_path)
 state.claim_login(now());nav.unlocked_level=state.level;quest_level=state.level
 player.configure(art,nav);player.position=Vector2(200,690)*2;world_player_position=player.position
 player.get_node("Camera2D").zoom=Vector2.ONE*0.85
 for pair in [["move_left",KEY_LEFT],["move_right",KEY_RIGHT],["move_up",KEY_UP],["move_down",KEY_DOWN]]:
  var event:=InputEventKey.new();event.physical_keycode=pair[1]
  if not InputMap.action_has_event(pair[0],event):InputMap.action_add_event(pair[0],event)
 setup_people();build_ui();build_world_objects();update_world();refresh_hud()
 if not state.difficulty_chosen:show_difficulty()
 elif not state.onboarded:show_guide(0)
 else:notify("Chào Momo! Nhấn ? để xem hướng dẫn; Tasks để xem việc cần làm.")
 save_game()
func current_texture()->Texture2D:return world if state.house_level>=2 else starter
func locked_regions()->Array[Rect2]:
 var regions:Array[Rect2]=[]
 if state.level==1:
  regions=[Rect2(0,0,3072,1200),Rect2(0,1640,3072,408),Rect2(0,1200,240,440),Rect2(1120,1200,1952,440)]
 elif state.level==2:regions=[Rect2(0,0,3072,560),Rect2(2400,560,672,1488)]
 elif state.level==3:regions=[Rect2(2000,0,1072,660)]
 if state.level>=2 and not state.orchard_open:regions.append(Rect2(960,1380,400,420))
 return regions
func _draw()->void:
 if world==null:return
 draw_texture_rect(current_texture(),Rect2(0,0,3072,2048),false)
 for r in locked_regions():
  draw_rect(r,Color("738c73"))
  for x in range(int(r.position.x)+60,int(r.end.x)-20,160):
   for y in range(int(r.position.y)+60,int(r.end.y)-20,150):draw_circle(Vector2(x,y),40,Color("80977b"))
func build_ui()->void:
 layer=CanvasLayer.new();add_child(layer)
 ui=Control.new();ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui.theme=Style.make();layer.add_child(ui)
 var hud_panel:=PanelContainer.new();hud_panel.position=Vector2(18,14);hud_panel.size=Vector2(440,84);ui.add_child(hud_panel)
 var hbox:=VBoxContainer.new();hud_panel.add_child(hbox)
 hud=Label.new();hud.add_theme_font_size_override("font_size",17);hbox.add_child(hud)
 bar=ProgressBar.new();bar.custom_minimum_size=Vector2(400,21);bar.max_value=3;bar.show_percentage=false;hbox.add_child(bar)
 var commands=[["Learn","book",open_learning],["Farm","leaf",show_farm],["Letters","mail",show_writing],["Settings","gear",show_settings],["Tasks","star",show_tasks],["Map","map",toggle_map],["? Help","help",show_help]]
 for i in range(commands.size()):
  var b:=Button.new();b.text=commands[i][0];b.icon=load("res://game/assets/ui/v3_"+str(commands[i][1])+".svg")
  b.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER;b.vertical_icon_alignment=VERTICAL_ALIGNMENT_TOP
  b.position=Vector2(18+i*110,610);b.size=Vector2(100,72)
  var action:Callable=commands[i][2]
  b.pressed.connect(func():
   if state.onboarded:action.call()
   else:notify("Hãy chọn độ khó và đọc hướng dẫn trước khi chơi."))
  ui.add_child(b);command_buttons.append(b)
 hint=Label.new();hint.position=Vector2(20,105);hint.add_theme_font_size_override("font_size",17)
 hint.add_theme_stylebox_override("normal",Style.box("fff6dfcc","afbb88",8));ui.add_child(hint)
 toast=Label.new();toast.position=Vector2(470,24);toast.custom_minimum_size=Vector2(620,48);toast.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 toast.add_theme_stylebox_override("normal",Style.box("fff0c9"));ui.add_child(toast);toast.hide()
 map_panel=PanelContainer.new();map_panel.position=Vector2(1010,14);map_panel.size=Vector2(252,200);ui.add_child(map_panel)
 var mv:=VBoxContainer.new();map_panel.add_child(mv)
 var mr:=HBoxContainer.new();mv.add_child(mr)
 var ml:=Label.new();ml.text="Town map";ml.size_flags_horizontal=Control.SIZE_EXPAND_FILL;mr.add_child(ml)
 make_button(mr,"×",func():map_panel.hide(),28)
 minimap=Mini.new();minimap.game=self;minimap.custom_minimum_size=Vector2(224,148);minimap.size=Vector2(224,148)
 minimap.gui_input.connect(func(e):
  if e is InputEventMouseButton and e.pressed and e.button_index==MOUSE_BUTTON_LEFT and not dialog.visible:
   if interior.visible:
    notify("Bản đồ chỉ để xem khi Momo đang ở trong phòng.")
    return
   var target:Vector2=e.position/minimap.size*Vector2(3072,2048)
   if nav.allowed(target):player.walk_to(target)
   else:notify("Khu vực này chưa mở. Hoàn thành 3 nhiệm vụ để lên cấp."))
 mv.add_child(minimap);map_panel.hide()
 dialog=PanelContainer.new();dialog.position=Vector2(704,110);dialog.size=Vector2(550,360);ui.add_child(dialog)
 var outer:=VBoxContainer.new();outer.add_theme_constant_override("separation",8);dialog.add_child(outer)
 var header:=HBoxContainer.new();outer.add_child(header)
 title_label=Label.new();title_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;title_label.add_theme_font_size_override("font_size",23);header.add_child(title_label)
 close_button=make_button(header,"×",close_dialog,36)
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size=Vector2(510,180);scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;outer.add_child(scroll)
 body=VBoxContainer.new();body.custom_minimum_size.x=482;body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_theme_constant_override("separation",10);scroll.add_child(body)
 feedback=Label.new();feedback.custom_minimum_size=Vector2(480,46);feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;outer.add_child(feedback)
 dialog.hide()
 room_layer=CanvasLayer.new();room_layer.layer=-1;add_child(room_layer)
 # Room is placed on layer 2, UI on layer 3 so dialogs stay visible.
 room_layer.layer=2;layer.layer=3
 interior=Room.new();room_layer.add_child(interior);interior.hide()
 room_ui=Control.new();room_ui.theme=ui.theme;room_ui.mouse_filter=Control.MOUSE_FILTER_IGNORE;room_ui.z_index=30;room_layer.add_child(room_ui);room_ui.hide()
 room_hint=Label.new();room_hint.position=Vector2(480,505);room_hint.custom_minimum_size=Vector2(320,42);room_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 room_hint.add_theme_stylebox_override("normal",Style.box("fff0c9","738b53",10));room_ui.add_child(room_hint)
func make_button(parent:Node,text:String,action:Callable,height:int=42)->Button:
 var b:=Button.new();b.text=text;b.custom_minimum_size.y=height;b.pressed.connect(action);parent.add_child(b);return b
func line(text:String,size:int=18)->Label:
 var l:=Label.new();l.text=text;l.custom_minimum_size.x=475;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",maxi(16,size+state.text_size-20));body.add_child(l);return l
func rich_line(text:String,height:int=58)->RichTextLabel:
 var r:=RichTextLabel.new()
 r.bbcode_enabled=true
 r.fit_content=true
 r.custom_minimum_size=Vector2(475,height)
 r.add_theme_font_size_override("normal_font_size",maxi(16,18+state.text_size-20))
 r.add_theme_font_size_override("bold_font_size",maxi(16,18+state.text_size-20))
 r.text=text
 body.add_child(r)
 return r
func open_dialog(id:String,title:String)->void:
 if not state.difficulty_chosen and id!="difficulty":return
 screen=id;fishing_running=false;player.stop();pending_npc="";pending_door=""
 for c in body.get_children():body.remove_child(c);c.queue_free()
 title_label.text=title;feedback.text="";feedback.modulate=Color.WHITE;close_button.disabled=false
 dialog.show()
 fit_dialog_layout()

func fit_dialog_layout()->void:
 if dialog==null or body==null:return
 var desired:float=clampf(body.get_combined_minimum_size().y+150.0,260.0,560.0)
 dialog.size=Vector2(550,desired)
 dialog.position=Vector2(365,60) if interior.visible else Vector2(704,110)

func close_dialog()->void:
 if screen=="difficulty" and not state.difficulty_chosen:return
 if screen=="guide" and not state.onboarded:
  finish_guide()
  notify("Có thể mở lại bằng ? Help hoặc F1.")
  return
 dialog.hide()
 fishing_running=false
 get_viewport().gui_release_focus()
func message(text:String,good:bool=true)->void:
 feedback.text=text;feedback.modulate=Color("466635") if good else Color("a44c32")
func notify(text:String)->void:toast.text=text;toast.show();toast_timer=6.0
func save_game()->void:
 if persistence_enabled and not state.save_to(save_path):notify("Không lưu được. Kiểm tra dung lượng và quyền ghi trên máy.")
func refresh_hud()->void:
 hud.text="Lv.%d • %d/3 việc  |  Cards %d  |  Powers %d"%[state.level,state.level_points(),state.cards,state.powers]
 if state.level==5:hud.text="Lv.5 • Hoàn thành chương thử  | Cards %d | Powers %d"%[state.cards,state.powers]
 bar.value=3 if state.level==5 else state.level_points()

func changed()->void:
 save_game()
 refresh_hud()
 update_world()
 if quest_level!=state.level:
  quest_level=state.level
  show_unlock_notice(state.level)

func _process(delta:float)->void:
 elapsed+=delta
 player.locked=not state.onboarded or dialog.visible or interior.visible or state.delivery_active
 if interior.visible and not dialog.visible:
  process_room_movement(delta)
 if not interior.visible:
  world_player_position=player.global_position
 player.z_index=int(player.position.y)
 if toast_timer>0:
  toast_timer-=delta
  if toast_timer<=0:toast.hide()
 if pending_npc!="" and not dialog.visible and not interior.visible:
  var npc_id:=pending_npc
  var n:=npc_by_id(npc_id)
  if not n.is_empty() and player.position.distance_to(n.at*2)<130:
   pending_npc=""
   interact_npc(npc_id)
 if pending_door!="" and not dialog.visible and not interior.visible:
  var door_id:=pending_door
  var n:=npc_by_id(door_id)
  if not n.is_empty() and player.position.distance_to(n.door*2)<130:
   pending_door=""
   enter_room(door_id)
 if state.delivery_active:tick_delivery(delta)
 if fishing_running:
  fishing_elapsed+=delta;fishing_position=fmod(fishing_elapsed*0.45,1.0)
  if is_instance_valid(fishing_slider):fishing_slider.value=fishing_position*100
 refresh_clock+=delta
 if refresh_clock>0.4:
  refresh_clock=0;refresh_crops();minimap.queue_redraw()
  if dialog.visible:fit_dialog_layout()
  if not interior.visible:
   var nearby:=nearest_npc()
   hint.text="[E] "+str(nearby.name)+" • "+str(nearby.role) if not nearby.is_empty() else "WASD / mũi tên: đi • nhấp NPC: đến nói chuyện • ?: hướng dẫn"
 if elapsed>=10800 and elapsed-delta<10800:notify("Bạn đã chơi 180 phút. Hãy nghỉ, vận động và thư giãn mắt.")

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
   for obj in data.objects:
    if Rect2(obj.rect).grow(12).has_point(point):
     room_action(str(obj.action))
     return
   if Rect2(data.floor_rect).has_point(point):
    room_target=point
    room_has_target=true
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

func toggle_map()->void:
 if not state.onboarded:return
 map_panel.visible=not map_panel.visible

func show_difficulty()->void:
 open_dialog("difficulty","Welcome, Momo!")
 dialog.position=Vector2(370,100)
 close_button.disabled=true
 line("Chọn mức phù hợp với khả năng tiếng Anh của bạn. Nếu mới học, chọn Easy (Dễ). Không cần tài khoản; tiến trình lưu trên máy.")
 for item in [["easy","Easy • Dễ (A1–A2)","Dành cho người mới học: từ quen thuộc và câu ngắn."],["normal","Normal • Vừa (B1–B2)","Dành cho người đã biết từ và câu cơ bản."],["hard","Hard • Khó (C1)","Dành cho người muốn luyện từ và cách diễn đạt nâng cao."]]:
  make_button(body,item[1],func():select_difficulty(item[0]),54)
  line(item[2],16)
 line("Độ khó theo khả năng tiếng Anh, không theo tuổi. Có thể đổi trong Settings.",16)
func select_difficulty(mode:String)->void:
 if state.choose_difficulty(mode):save_game();show_guide(0)


func show_guide(index:int)->void:
 if not state.difficulty_chosen:return
 guide_index=clampi(index,0,GUIDE_PAGES.size()-1)
 open_dialog("guide","Hướng dẫn • %d/%d"%[guide_index+1,GUIDE_PAGES.size()])
 line(GUIDE_PAGES[guide_index][0],22)
 line(GUIDE_PAGES[guide_index][1],17)
 var nav_row:=HBoxContainer.new()
 nav_row.add_theme_constant_override("separation",12)
 body.add_child(nav_row)
 if guide_index>0:
  var prev:=make_button(nav_row,"← Bước trước",func():show_guide(guide_index-1),48)
  prev.custom_minimum_size.x=190
 else:
  var spacer:=Control.new()
  spacer.custom_minimum_size=Vector2(190,48)
  nav_row.add_child(spacer)
 if guide_index<GUIDE_PAGES.size()-1:
  var next:=make_button(nav_row,"Bước tiếp theo →",func():show_guide(guide_index+1),48)
  next.custom_minimum_size.x=220
 else:
  var start:=make_button(nav_row,"Bắt đầu chơi",finish_guide,52)
  start.custom_minimum_size.x=220
 if not state.onboarded:
  make_button(body,"Bỏ qua",func():finish_guide();notify("Có thể mở lại toàn bộ hướng dẫn bằng ? Help hoặc F1."),38)

func finish_guide()->void:
 state.onboarded=true
 dialog.hide()
 save_game()
 notify("Bắt đầu cấp 1: học 3 từ → làm bài đọc nhận hạt → thu hoạch 3 củ. Bấm Tasks (Nhiệm vụ) để theo dõi.")

func show_help()->void:
 show_guide(0)
func tip_once(key:String,text:String)->void:
 var flag:="tip:"+key
 if state.studied.get(flag,false):return
 state.studied[flag]=true
 save_game()
 notify(text)

func show_unlock_notice(level:int)->void:
 var text:=""
 match level:
  2:text="Đã mở xe hàng, Chợ và Bưu điện."
  3:text="Đã mở Xưởng, Ngân hàng và Câu cá."
  4:text="Đã mở Vườn cây và cửa hàng mở rộng."
  5:text="Bạn đã hoàn thành chương thử."
 if text.is_empty():return
 open_dialog("unlock","Mở khóa mới")
 line(text,20)
 make_button(body,"Xem hướng dẫn",show_help,48)
 make_button(body,"Tiếp tục chơi",close_dialog,42)

func open_learning()->void:
 if not state.difficulty_chosen:return
 open_dialog("learn","Learn • Học và luyện tập")
 tip_once("learn","Học 3 từ rồi làm bài kiểm tra.")
 line("Chọn nội dung để học trước. Bài kiểm tra chỉ mở sau khi bạn đã xem phần kiến thức.")
 for item in [["Vocabulary • Từ vựng",func():show_vocabulary(0)],["Grammar • Ngữ pháp",show_grammar],["Reading • Kỹ năng đọc",show_reading],["Writing • Kỹ năng viết",show_writing_lesson],["Places • Tên các địa điểm",show_places]]:make_button(body,item[0],item[1])
func show_vocabulary(index:int)->void:
 open_dialog("vocabulary","Vocabulary • %d/3"%(index+1));seen_words[state.difficulty+":"+str(index)]=true
 var w:Dictionary=curriculum.words[state.difficulty][index]
 line(w.word,30);line(w.ipa+"  •  "+w.stress,17)
 line("Nghĩa: "+w.vi,21);line(w.explanation);line("Use • "+w.use)
 line("Example • "+w.example);line(w.translation,16)
 make_button(body,"Nghe phát âm • giọng hệ thống",func():speak(w.word))
 if index>0:make_button(body,"← Từ trước",func():show_vocabulary(index-1))
 if index<2:make_button(body,"Từ tiếp theo →",func():show_vocabulary(index+1))
 var all_seen:=true
 for i in range(3):
  if not seen_words.has(state.difficulty+":"+str(i)):all_seen=false
 if all_seen:make_button(body,"Đã học 3 từ • Bắt đầu quiz",func():mark_studied("vocabulary");start_quiz("vocabulary"))
 make_button(body,"← Các mục học",open_learning)
func speak(word:String)->void:
 var voices=DisplayServer.tts_get_voices_for_language("en")
 if voices.is_empty():message("Máy chưa có giọng đọc tiếng Anh. Bạn vẫn có thể xem IPA và trọng âm trên thẻ.",false)
 else:DisplayServer.tts_speak(word,voices[0],70,1.0,0.85)
func mark_studied(topic:String)->void:state.study(topic);save_game()
func show_grammar()->void:
 open_dialog("grammar","Grammar • Học cấu trúc")
 var g:Dictionary=curriculum.grammar[state.difficulty]
 line(g.title,22)
 for pair in [["Form",g.form],["Meaning",g.meaning],["Use",g.use]]:line(pair[0]+" • "+pair[1])
 for example in g.examples:line(example)
 make_button(body,"Đã học • Làm bài ngữ pháp",func():mark_studied("grammar");start_quiz("grammar"))
func show_reading()->void:
 open_dialog("reading","Reading • Đọc có mục đích")
 for step in curriculum.reading.steps:line(step)
 line(curriculum.reading.strategy,17);line(curriculum.reading.example)
 line("Đoạn đọc của bạn",22);line(lessons[state.difficulty].passage)
 make_button(body,"Đã đọc hướng dẫn • Trả lời 3 câu",func():mark_studied("reading");start_quiz("reading"))
func show_writing_lesson()->void:
 open_dialog("writing_lesson","Writing • Viết thư rõ ý")
 for step in curriculum.writing.steps:line(step)
 line("Bài mẫu",22);line(curriculum.writing.example);line(curriculum.writing.note,16)
 make_button(body,"Đã học • Tập viết",func():mark_studied("writing");show_writing())
func show_places()->void:
 open_dialog("places","Places • Địa điểm trong thị trấn")
 for p in curriculum.places:
  line(p[0]+" — "+p[2],22);line(p[1]+"\n"+p[3]+"\n"+p[4],17)
 make_button(body,"Đã học tên địa điểm",func():mark_studied("places");close_dialog())
func start_quiz(kind:String)->void:
 if not state.can_test(kind):
  if kind=="vocabulary":show_vocabulary(0)
  elif kind=="grammar":show_grammar()
  else:show_reading()
  return
 quiz_kind=kind;quiz_index=0;show_quiz_question()
func show_quiz_question()->void:
 open_dialog("quiz","Practice • %d/3"%(quiz_index+1))
 var p:=ProgressBar.new();p.max_value=3;p.value=quiz_index;p.custom_minimum_size.y=18;body.add_child(p)
 if quiz_kind=="vocabulary":
  var w:Dictionary=curriculum.words[state.difficulty][quiz_index]
  line("Từ nào có nghĩa: "+w.vi+"?",23);line(w.explanation)
  quiz_answers=[w.word]
  var choices:Array=[]
  for word in curriculum.words[state.difficulty]:choices.append(str(word.word))
  choices.shuffle()
  for choice in choices:make_button(body,choice,func():answer_quiz(choice),48)
 elif quiz_kind=="grammar":
  var q:Array=curriculum.grammar[state.difficulty].questions[quiz_index]
  line(q[0],23);quiz_answers=[str(q[2]).to_lower()]
  var choices:Array=q[1].duplicate();choices.shuffle()
  for choice in choices:make_button(body,choice,func():answer_quiz(choice),48)
 else:
  var q:Dictionary=lessons[state.difficulty].questions[quiz_index]
  line(lessons[state.difficulty].passage,17);line(q.prompt,23);quiz_answers=q.answers
  quiz_input=LineEdit.new();quiz_input.placeholder_text="Nhập câu trả lời ngắn";body.add_child(quiz_input)
  make_button(body,"Kiểm tra",func():answer_quiz(quiz_input.text))
 make_button(body,"Gợi ý • 1 Power",func():
  if state.spend_power():changed();message("Đáp án bắt đầu bằng: "+str(quiz_answers[0]).left(1))
  else:message("Hết Power. Có thể quay lại bài học để xem kiến thức.",false))
 make_button(body,"Xem lại bài học",func():
  if quiz_kind=="vocabulary":show_vocabulary(quiz_index)
  elif quiz_kind=="grammar":show_grammar()
  else:show_reading())
func answer_quiz(answer:String)->void:
 if answer.strip_edges().to_lower() not in quiz_answers:
  message("Chưa đúng. Xem lại bài học hoặc thử đáp án khác; chưa bị trừ thẻ.",false);return
 if quiz_kind=="vocabulary":
  var word:String=curriculum.words[state.difficulty][quiz_index].word
  if state.learned.has(word):state.review_word(word,now())
  else:state.learn_word(word,now())
 quiz_index+=1
 if quiz_index<3:show_quiz_question();changed();return
 if quiz_kind=="reading":state.unlock_seeds("carrot-"+state.difficulty,3,3)
 state.complete_task(quiz_kind)
 changed();open_dialog("quiz_done","Hoàn thành • 3/3")
 line("Bạn đã vận dụng đúng kiến thức!",24)
 line("Đã nhận 3 hạt giống nếu đây là lần hoàn thành đầu tiên ở mức này." if quiz_kind=="reading" else "Tiến trình đã lưu. Phần thưởng học từ được tính một lần; ôn có thưởng sau 24 giờ.")
 make_button(body,"Xem nhiệm vụ tiếp theo",show_tasks)
func show_tasks()->void:
 open_dialog("tasks","Level %d • Mục tiêu hôm nay"%state.level)
 line("Mỗi nhiệm vụ của cấp hiện tại làm đầy 1/3 thanh tiến trình. Hoàn thành cả 3: tự lên cấp và nhận 1 Power (lượt gợi ý).")
 for id in State.LEVEL_TASKS.get(state.level,[]):
  line(("✓ " if state.completed.has(id) else "○ ")+str(TASK_NAMES[id]),21)
  if not state.completed.has(id):make_button(body,"Thực hiện",func():route_task(id))
 if state.level==5:line("Bạn đã hoàn thành chương thử! Tiếp tục ôn từ, chăm vườn, viết thư, câu cá và quản lý thẻ.")
func route_task(id:String)->void:
 match id:
  "vocabulary":show_vocabulary(0)
  "reading":show_reading()
  "harvest":show_farm()
  "grammar":show_grammar()
  "letter":show_writing_lesson()
  "delivery":interact_npc("mia")
  "house":interact_npc("ben")
  "fishing":interact_npc("noah")
  "bank":interact_npc("clara")
  _:show_shop()
func show_writing()->void:
 if not state.can_test("writing"):show_writing_lesson();return
 open_dialog("letters","Letters • Viết và gửi thư")
 line(lessons[state.difficulty].writing,17)
 writing=TextEdit.new();writing.custom_minimum_size=Vector2(470,140);writing.text=state.letter_draft;writing.placeholder_text="Dear Mia, ...";body.add_child(writing)
 writing.text_changed.connect(func():state.letter_draft=writing.text.left(10000);save_game())
 line("Tự kiểm: có lời chào • trả lời yêu cầu • thời gian/số lượng • lời kết. Thư chỉ lưu trên máy; chưa chấm AI.",16)
 make_button(body,"Tôi đã kiểm tra • Gửi cho Emma",func():
  if state.level<2:message("Bài viết đã lưu; nhiệm vụ gửi thư mở ở cấp 2.",false);return
  if writing.text.strip_edges().split(" ",false).size()<10:message("Hãy viết ít nhất 10 từ để thực hành một thư ngắn.",false);return
  var first:bool=state.complete_task("letter")
  if first:state.cards+=3;state.friendship["emma"]=1
  changed();message("Emma đã nhận thư. +3 cards cho lần đầu. Đây là xác nhận luyện tập, không phải đánh giá chất lượng tiếng Anh."))
 make_button(body,"Xem cấu trúc và bài mẫu",show_writing_lesson)
func show_farm()->void:
 open_dialog("farm","Farm • Khu vườn nhỏ")
 line("Hạt: %d | Cà rốt: %d\nPlant = Gieo hạt • Water = Tưới cây • Harvest = Thu hoạch"%[state.seeds,state.produce],17)
 line("Chế độ nhanh: cây lớn sau 20 giây; héo nếu quá 60 giây không tưới." if state.demo_mode else "Thời gian thực: cây lớn sau 12 giờ; héo nếu quá 12 giờ không tưới.",16)
 for i in range(6 if state.orchard_open else 3):
  var row:=HBoxContainer.new();body.add_child(row)
  var l:=Label.new();l.text="Ô%d • %s"%[i+1,state.crop_status(i,crop_time())];l.custom_minimum_size.x=165;row.add_child(l)
  for pair in [["Gieo (Plant)","plant"],["Tưới (Water)","water"],["Thu hoạch (Harvest)","harvest"]]:make_button(row,pair[0],func():farm_action(pair[1],i),36)
 make_button(body,"Cập nhật tình trạng cây",show_farm)
 make_button(body,"Mua 3 hạt • 3 cards",func():
  if state.unlocked.is_empty():message("Học và hoàn thành bài đọc để mở loại hạt trước.",false);return
  if state.cards<3:message("Cần 3 cards. Học từ mới hoặc ôn từ đến hạn để nhận thẻ.",false);return
  state.cards-=3;state.seeds+=3;changed();show_farm();message("Đã mua 3 hạt."))
 make_button(body,"Học hướng dẫn đọc để nhận hạt",show_reading)
func farm_action(action:String,index:int)->void:
 var ok:=false
 if index>=3 and not state.orchard_open:return
 match action:
  "plant":ok=state.plant(index,crop_time())
  "water":ok=state.water(index,crop_time())
  "harvest":ok=state.harvest(index,crop_time())>0
 changed();show_farm();refresh_crops()
 message("Xong! Harvest nhận 1 cà rốt và 2 cards." if ok and action=="harvest" else ("Đã thực hiện." if ok else "Kiểm tra hạt, tuổi cây hoặc hạn tưới. Ô héo có thể gieo lại."),ok)

func show_settings()->void:
 open_dialog("settings","Settings • Tùy chọn")
 line("Độ khó tiếng Anh",21)
 for item in [["easy","Easy • Dễ"],["normal","Normal • Vừa"],["hard","Hard • Khó"]]:
  var mode:String=item[0]
  make_button(body,item[1]+(" ✓" if state.difficulty==mode else ""),func():state.choose_difficulty(mode);changed();show_settings())
 line("Cỡ chữ",21)
 var slider:=HSlider.new()
 slider.min_value=16;slider.max_value=24;slider.step=1;slider.value=state.text_size
 body.add_child(slider)
 slider.value_changed.connect(func(v):
  state.text_size=int(v)
  ui.theme.default_font_size=int(v)
  save_game()
  call_deferred("show_settings"))
 var trial:=CheckButton.new()
 trial.text="Chế độ thử nhanh (tắt = 12 giờ)"
 trial.button_pressed=state.demo_mode
 body.add_child(trial)
 trial.toggled.connect(func(on):
  for p in state.plots:
   if not p.is_empty():
    trial.set_pressed_no_signal(state.demo_mode)
    message("Hãy thu hoạch hoặc dọn hết cây trước khi đổi thời gian.",false)
    return
  state.demo_mode=on
  changed())
 make_button(body,"Dọn các ô cây đã héo",func():
  for i in range(6):
   if state.crop_status(i,crop_time())=="wilted":state.plots[i]={}
  changed();refresh_crops();message("Đã dọn cây héo; từ đã học vẫn giữ nguyên."))
 line("Dữ liệu được tự lưu trên máy. Không cần tài khoản.",16)
 make_button(body,"Xóa dữ liệu game • Reset",show_reset_confirm,46)

func show_reset_confirm()->void:
 open_dialog("reset","Xóa toàn bộ dữ liệu game?")
 line("Reset sẽ xóa cấp độ, Cards, Powers, từ đã học, cây trồng, thư nháp và toàn bộ tiến trình hiện tại.",18)
 line("Hành động này không thể hoàn tác. Sau khi xóa, game sẽ khởi động lại từ màn hình chọn độ khó.",16)
 var row:=HBoxContainer.new()
 row.add_theme_constant_override("separation",12)
 body.add_child(row)
 var cancel:=make_button(row,"Hủy",show_settings,48)
 cancel.custom_minimum_size.x=180
 var erase:=make_button(row,"Xóa dữ liệu và chơi lại",reset_game_data,48)
 erase.custom_minimum_size.x=260

func erase_save_file()->bool:
 if not FileAccess.file_exists(save_path):return true
 return DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))==OK

func reset_game_data()->void:
 if not erase_save_file():
  message("Không thể xóa dữ liệu lưu. Hãy kiểm tra quyền ghi của thư mục game.",false)
  return
 persistence_enabled=false
 get_tree().reload_current_scene()
func setup_people()->void:
 npc_data=[
 {"id":"home","name":"Momo","role":"Nhà của bạn","relation":"Căn nhà và khu vườn đầu tiên của bạn.","place":"Nông trại (Farm)","at":Vector2(200,690),"door":Vector2(190,680),"exit":Vector2(190,735),"sprite":0,"level":1},
 {"id":"lily","name":"Lily","role":"Thủ thư","relation":"Người hướng dẫn học tập của Momo.","place":"Thư viện (Library)","at":Vector2(365,660),"door":Vector2(438,307),"exit":Vector2(438,362),"sprite":0,"level":1},
 {"id":"tom","name":"Tom","role":"Nông dân","relation":"Hàng xóm dạy Momo chăm vườn.","place":"Khu vườn (Garden)","at":Vector2(440,640),"door":Vector2(450,650),"exit":Vector2(450,705),"sprite":1,"level":1},
 {"id":"mia","name":"Mia","role":"Chủ tiệm","relation":"Khách hàng đầu tiên của Momo.","place":"Chợ (Market)","at":Vector2(920,580),"door":Vector2(940,590),"exit":Vector2(940,645),"sprite":2,"level":2},
 {"id":"emma","name":"Emma","role":"Bưu tá","relation":"Bạn giúp Momo trao đổi thư từ.","place":"Bưu điện (Post Office)","at":Vector2(1090,751),"door":Vector2(1020,756),"exit":Vector2(1020,811),"sprite":0,"level":2},
 {"id":"ben","name":"Ben","role":"Thợ mộc","relation":"Người giúp Momo sửa nhà.","place":"Xưởng mộc (Workshop)","at":Vector2(275,520),"door":Vector2(250,514),"exit":Vector2(250,569),"sprite":1,"level":3},
 {"id":"clara","name":"Clara","role":"Nhân viên ngân hàng","relation":"Người giữ thẻ tiết kiệm cho Momo.","place":"Ngân hàng (Bank)","at":Vector2(810,264),"door":Vector2(810,250),"exit":Vector2(810,305),"sprite":2,"level":3},
 {"id":"noah","name":"Noah","role":"Người câu cá","relation":"Bạn dạy Momo câu cá.","place":"Bến câu (Pier)","at":Vector2(1340,781),"door":Vector2(1310,778),"exit":Vector2(1310,833),"sprite":1,"level":3}]
 for n in npc_data:
  if n.id!="home":
   var node:=Node2D.new();var v=art.animated("npcs",{"idle":[n.sprite,n.sprite+3]},62.0);node.add_child(v);v.play("idle")
   var label:=Label.new();label.text=n.name+"\n"+n.role;label.position=Vector2(-65,-105);label.add_theme_font_size_override("font_size",16)
   label.add_theme_color_override("font_color",Color("342b24"));label.add_theme_stylebox_override("normal",Style.box("f9edcd"));node.add_child(label)
   add_child(node);npc_nodes[n.id]=node
  var sign:=Label.new();sign.text=n.place+"\nNhấn E để vào";sign.position=n.door*2+Vector2(-65,0);sign.z_index=3000
  sign.add_theme_font_size_override("font_size",15);sign.add_theme_color_override("font_color",Color("40362b"));sign.add_theme_stylebox_override("normal",Style.box("f1e1b6"))
  add_child(sign);door_nodes[n.id]=sign
func npc_by_id(id:String)->Dictionary:
 for n in npc_data:
  if n.id==id:return n
 return {}
func nearest_npc()->Dictionary:
 var best:Dictionary={};var distance:=140.0
 for n in npc_data:
  if state.level<n.level:continue
  var d:float=player.position.distance_to(n.at*2)
  if d<distance:distance=d;best=n
 return best

func interact_npc(id:String)->void:
 var n:=npc_by_id(id)
 if n.is_empty():return
 if state.level<n.level:
  notify("%s mở ở cấp %d."%[n.place,n.level])
  return
 if id=="home":
  pending_npc=""
  enter_room(id)
  return
 open_dialog("npc",n.name+" • "+str(n.role))
 line(n.place,22)
 line(n.relation)
 line("Tình bạn: %d"%int(state.friendship.get(id,0)),16)
 match id:
  "lily":
   line("Học kiến thức trước, rồi thử sức khi đã sẵn sàng.")
   make_button(body,"Học cùng Lily",open_learning)
  "tom":
   line("Nhận hạt, gieo, tưới rồi thu hoạch 3 củ cà rốt.")
   make_button(body,"Chăm khu vườn",show_farm)
  "mia":
   line("Mia cần 3 củ cà rốt. Giao đủ để nhận cards, gỗ và tình bạn.")
   make_button(body,"Nhận đơn hàng",func():
    message("Đã nhận đơn! Chuẩn bị 3 củ cà rốt." if state.accept_order() else "Đơn đã được nhận hoặc hoàn thành.")
    changed())
   make_button(body,"Chất hàng • 3 cà rốt",begin_delivery)
  "emma":
   line("Học cách viết thư, rồi soạn một lời nhắn ngắn và rõ ý.")
   make_button(body,"Học viết thư",show_writing_lesson)
  "ben":
   line("Dùng 5 gỗ để sửa nhà. Gỗ nhận từ đơn hàng của Mia.")
   make_button(body,"Mở bàn thợ",show_workshop)
  "clara":
   line("Gửi hoặc rút Word Cards trong sổ tiết kiệm của Momo.")
   make_button(body,"Mở sổ tiết kiệm",show_bank)
  "noah":
   line("Thả câu rồi bấm Kéo khi kim nằm trong vùng 40–70.")
   make_button(body,"Thử câu cá",show_fishing)
 if not interior.visible and id not in ["tom","noah"] and not (id=="lily" and state.level<2):
  make_button(body,"Vào "+str(n.place),func():enter_room(id))


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
 for b in command_buttons:
  b.visible=b.text in ["Farm","Letters","Settings","Tasks","Map","? Help"]
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
 player.position=Vector2(640,500)
 player.show()
 tip_once("room","Nhấn Esc để ra ngoài.")
 update_room_hint()

func leave_room()->void:
 var room_id:=current_room
 var n:=npc_by_id(room_id)
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
 hint.show()
 for b in command_buttons:b.show()
 get_viewport().gui_release_focus()

func safe_walkable_near(pt:Vector2)->Vector2:
 return nav.safe_walkable_near(pt)

func has_walkable_step(from:Vector2,toward:Vector2=Vector2.INF)->bool:
 return nav.has_walkable_step(from,toward)

func process_room_movement(delta:float)->void:
 if current_room.is_empty():return
 var data:Dictionary=interior.room_data(current_room)
 var floor:Rect2=data.floor_rect
 var move:Vector2=Input.get_vector("move_left","move_right","move_up","move_down")
 var motion:Vector2=Vector2.ZERO
 if move.length_squared()>0.01:
  room_has_target=false
  motion=move.normalized()*260.0*minf(delta,0.05)
 elif room_has_target:
  var distance:float=player.position.distance_to(room_target)
  if distance<5:
   room_has_target=false
  else:
   motion=player.position.direction_to(room_target)*minf(260.0*minf(delta,0.05),distance)
 if motion!=Vector2.ZERO:
  var next:Vector2=player.position+motion
  next.x=clampf(next.x,floor.position.x+24,floor.end.x-24)
  next.y=clampf(next.y,floor.position.y+24,floor.end.y-24)
  player.position=next
 update_room_hint()

func nearest_room_object()->Dictionary:
 if current_room.is_empty():return {}
 var data:Dictionary=interior.room_data(current_room)
 var best:Dictionary={}
 var best_distance:=100.0
 for obj in data.objects:
  var d:float=player.position.distance_to(Rect2(obj.rect).get_center())
  if d<best_distance:
   best_distance=d
   best=obj
 return best

func update_room_hint()->void:
 if not interior.visible:return
 var data:Dictionary=interior.room_data(current_room)
 if Rect2(data.exit_zone).grow(35).has_point(player.position):
  room_hint.text="[E] Ra ngoài"
  return
 var obj:=nearest_room_object()
 room_hint.text="[E] "+str(obj.label) if not obj.is_empty() else "WASD / mũi tên hoặc bấm sàn để di chuyển"

func room_interact()->void:
 if current_room.is_empty():return
 var data:Dictionary=interior.room_data(current_room)
 if Rect2(data.exit_zone).grow(35).has_point(player.position):
  leave_room()
  return
 var obj:=nearest_room_object()
 if not obj.is_empty():room_action(str(obj.action))

func room_action(action:String)->void:
 room_has_target=false
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
  "bank":show_bank()
  "farm":show_farm()
  "fishing":show_fishing()
func show_workshop()->void:
 if state.level<3:
  notify("Xưởng mở ở cấp 3.")
  return
 open_dialog("workshop","Xưởng Ben • Sửa nhà")
 line("Gỗ: %d / 5"%state.wood,24)
 var progress:=ProgressBar.new()
 progress.max_value=5
 progress.value=min(state.wood,5)
 progress.show_percentage=false
 progress.custom_minimum_size=Vector2(470,24)
 body.add_child(progress)
 line("Dùng 5 gỗ để nâng cấp căn nhà của Momo.",18)
 make_button(body,"Sửa nhà • 5 gỗ",func():
  var ok:bool=state.improve_home()
  changed()
  show_workshop()
  message("Nhà đã được nâng cấp!" if ok else "Cần 5 gỗ hoặc nhà đã được sửa.",ok),48)

func show_bank()->void:
 if state.level<3:notify("Ngân hàng mở ở cấp 3.");return
 open_dialog("bank","Bank • Sổ tiết kiệm")
 line("Wallet: %d cards\nSavings: %d cards"%[state.cards,state.bank_balance],24)
 line("Deposit = gửi vào • Withdraw = rút ra. Chỉ là thẻ trong game; không lãi/phí.")
 for amount in [1,5]:
  make_button(body,"Deposit %d cards"%amount,func():var ok:bool=state.deposit(amount);changed();show_bank();message("Đã gửi thẻ." if ok else "Không đủ thẻ trong ví.",ok))
  make_button(body,"Withdraw %d cards"%amount,func():var ok:bool=state.withdraw(amount);changed();show_bank();message("Đã rút thẻ." if ok else "Không đủ thẻ tiết kiệm.",ok))
func show_fishing()->void:
 if state.level<3:notify("Bến câu mở ở cấp 3.");return
 open_dialog("fishing","Fishing • Câu cá với Noah")
 line("Rod = cần câu • fish = cá • catch = bắt",20)
 line("1. Thả câu. 2. Quan sát kim chạy. 3. Bấm Kéo khi kim ở 40–70. Đúng nhận 1 cá, +3 cards; thưởng tối đa 1 lần/ngày.")
 fishing_slider=ProgressBar.new();fishing_slider.max_value=100;fishing_slider.custom_minimum_size.y=32;body.add_child(fishing_slider)
 line("Vùng bắt cá: 40–70",21)
 make_button(body,"Thả câu",func():fishing_elapsed=0;fishing_running=true;message("Chờ kim vào khoảng 40–70 rồi Kéo!"))
 make_button(body,"Kéo!",func():
  if not fishing_running:message("Hãy thả câu trước.",false);return
  fishing_running=false
  var in_zone:bool=fishing_position>=0.4 and fishing_position<=0.7
  var ok:bool=state.catch_fish(in_zone)
  changed();message("Bắt được cá! +3 cards." if ok else ("Hôm nay đã nhận thưởng câu cá; có thể tập lại." if in_zone else "Chưa đúng lúc. Thả câu và thử lại nhé."),ok))

func show_shop()->void:
 open_dialog("shop","Cửa hàng Mia • Vật phẩm")
 line("Cards hiện có: %d"%state.cards,20)
 var items=[
  {"label":"Mở vườn cây • 6 cards","level":4,"owned":state.orchard_open,"action":state.expand_orchard},
  {"label":"Mũ mới • 4 cards","level":4,"owned":state.outfit_owned,"action":state.buy_outfit},
  {"label":"1 Năng lượng (Power) • 3 cards","level":4,"owned":false,"action":state.buy_power}
 ]
 for item in items:
  var text:String=item.label
  if item.owned:text+=" • Đã có"
  elif state.level<int(item.level):text+=" • Mở ở cấp %d"%int(item.level)
  var b:=make_button(body,text,func():
   var ok:bool=item.action.call()
   changed()
   show_shop()
   message("Đã mua / mở thành công." if ok else "Không đủ cards hoặc vật phẩm đã sở hữu.",ok),46)
  b.disabled=item.owned or state.level<int(item.level)
 if state.orchard_open:
  line("Vườn cây đã mở. Sáu ô gieo trồng đã sẵn sàng.",17)
func build_world_objects()->void:
 var positions=[Vector2(209,712),Vector2(278,699),Vector2(358,684),Vector2(219,732),Vector2(291,720),Vector2(377,706)]
 for pos in positions:
  var node:=Node2D.new();node.position=pos*2;node.z_index=int(node.position.y);add_child(node);crop_nodes.append(node);crop_stages.append("")
 truck=load("res://game/scripts/journey_truck.gd").new();add_child(truck);truck.hide()
 if state.delivery_active:prepare_truck_route()
func prepare_truck_route()->void:
 var mia:=npc_by_id("mia")
 if mia.is_empty():
  state.delivery_active=false
  return
 truck_route=nav.find_path(Vector2(220,680)*2,Vector2(mia.at)*2)
 if truck_route.is_empty():
  state.delivery_active=false;save_game();notify("Xe chưa tìm được đường. Hàng vẫn được giữ; thử lại.")
func begin_delivery()->void:
 if not state.start_delivery():message("Nhận đơn và chuẩn bị 3 củ cà rốt trước; xe không nhận hai chuyến cùng lúc.",false);return
 player.stop();prepare_truck_route();close_dialog();changed();notify("Xe đang chở 3 cà rốt tới chợ. Thưởng nhận khi xe đến nơi.")
func tick_delivery(delta:float)->void:
 if not state.delivery_active:return
 if truck_route.is_empty():prepare_truck_route()
 if truck_route.is_empty():return
 state.delivery_seconds+=delta
 var t:float=clampf(state.delivery_seconds/12.0,0,1)
 var offset:float=t*(truck_route.size()-1)
 var a:=int(floor(offset));var b:=mini(a+1,truck_route.size()-1)
 truck.position=truck_route[a].lerp(truck_route[b],offset-a);truck.z_index=int(truck.position.y)+1;truck.show()
 player.position=truck.position;player.hide()
 if state.delivery_seconds>=12:
  var ok:bool=state.finish_delivery();truck.hide();player.show()
  var mia:=npc_by_id("mia")
  player.position=(Vector2(mia.get("exit",mia.at)) if not mia.is_empty() else Vector2(980,560))*2
  changed()
  if ok:notify("Mia đã nhận hàng! +8 cards, +5 gỗ và tình bạn. Xem Tasks để làm việc tiếp theo.")
func update_world()->void:
 nav.unlocked_level=state.level
 for n in npc_data:
  if n.id=="lily":n.at=Vector2(365,660) if state.level==1 else Vector2(438,307)
  if npc_nodes.has(n.id):
   var node:Node2D=npc_nodes[n.id];node.position=n.at*2;node.z_index=int(node.position.y);node.visible=state.level>=n.level
  if door_nodes.has(n.id):door_nodes[n.id].visible=state.level>=n.level and nav.allowed(n.door*2)
 if is_instance_valid(player.hat):player.hat.visible=state.outfit_owned
 if is_instance_valid(minimap):minimap.queue_redraw()
 queue_redraw()
func refresh_crops()->void:
 for i in range(crop_nodes.size()):
  var stage:String=state.crop_status(i,crop_time())
  crop_nodes[i].visible=i<3 or state.orchard_open
  if stage==crop_stages[i]:continue
  crop_stages[i]=stage
  for c in crop_nodes[i].get_children():c.queue_free()
  if stage!="empty":
   var sprite=art.sprite("items",1 if stage=="growing" else 3,48.0)
   if stage=="wilted":sprite.modulate=Color("826b4e")
   crop_nodes[i].add_child(sprite)
func _notification(what:int)->void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST:save_game()
