extends Node2D
const State=preload("res://game/scripts/journey_state.gd")
const Art=preload("res://game/scripts/art.gd")
const Nav=preload("res://game/scripts/journey_navigation.gd")
const Style=preload("res://game/scripts/journey_theme.gd")
const Mini=preload("res://game/scripts/journey_map.gd")
const Room=preload("res://game/scripts/journey_room.gd")
const SAVE="user://englishfarm_journey_v3.json"
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
var room_ui:Control
var current_room:=""
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
 if persistence_enabled:state.load_from(SAVE)
 state.claim_login(now());nav.unlocked_level=state.level;quest_level=state.level
 player.configure(art,nav);player.position=Vector2(200,690)*2
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
 var commands=[["Learn","book",open_learning],["Farm","leaf",show_farm],["Letters","mail",show_writing],["Settings","gear",show_settings],["Tasks","star",show_tasks],["Map","map",toggle_map],["? Help","help",func():show_guide(0)]]
 for i in range(commands.size()):
  var b:=Button.new();b.text=commands[i][0];b.icon=load("res://game/assets/ui/v3_"+str(commands[i][1])+".svg")
  b.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER;b.vertical_icon_alignment=VERTICAL_ALIGNMENT_TOP
  b.position=Vector2(18+i*110,630);b.size=Vector2(100,72)
  var action:Callable=commands[i][2]
  b.pressed.connect(func():
   if state.onboarded:action.call()
   else:notify("Hãy chọn độ khó và đọc hướng dẫn trước khi chơi."))
  ui.add_child(b)
 hint=Label.new();hint.position=Vector2(20,105);hint.add_theme_font_size_override("font_size",17);ui.add_child(hint)
 toast=Label.new();toast.position=Vector2(22,580);toast.custom_minimum_size=Vector2(610,40);toast.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 toast.add_theme_stylebox_override("normal",Style.box("fff0c9"));ui.add_child(toast);toast.hide()
 map_panel=PanelContainer.new();map_panel.position=Vector2(1010,14);map_panel.size=Vector2(252,200);ui.add_child(map_panel)
 var mv:=VBoxContainer.new();map_panel.add_child(mv)
 var mr:=HBoxContainer.new();mv.add_child(mr)
 var ml:=Label.new();ml.text="Town map";ml.size_flags_horizontal=Control.SIZE_EXPAND_FILL;mr.add_child(ml)
 make_button(mr,"×",func():map_panel.hide(),28)
 minimap=Mini.new();minimap.game=self;minimap.custom_minimum_size=Vector2(224,148);minimap.size=Vector2(224,148)
 minimap.gui_input.connect(func(e):
  if e is InputEventMouseButton and e.pressed and e.button_index==MOUSE_BUTTON_LEFT and not dialog.visible:
   var target:Vector2=e.position/minimap.size*Vector2(3072,2048)
   if nav.allowed(target):player.walk_to(target)
   else:notify("Khu vực này chưa mở. Hoàn thành 3 nhiệm vụ để lên cấp."))
 mv.add_child(minimap);map_panel.hide()
 dialog=PanelContainer.new();dialog.position=Vector2(704,140);dialog.size=Vector2(550,470);ui.add_child(dialog)
 var outer:=VBoxContainer.new();outer.add_theme_constant_override("separation",8);dialog.add_child(outer)
 var header:=HBoxContainer.new();outer.add_child(header)
 title_label=Label.new();title_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;title_label.add_theme_font_size_override("font_size",23);header.add_child(title_label)
 close_button=make_button(header,"×",close_dialog,36)
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size=Vector2(510,335);scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;outer.add_child(scroll)
 body=VBoxContainer.new();body.custom_minimum_size.x=482;body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_theme_constant_override("separation",10);scroll.add_child(body)
 feedback=Label.new();feedback.custom_minimum_size=Vector2(480,46);feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;outer.add_child(feedback)
 dialog.hide()
 var room_layer:=CanvasLayer.new();room_layer.layer=-1;add_child(room_layer)
 # Room is placed on layer 2, UI on layer 3 so dialogs stay visible.
 room_layer.layer=2;layer.layer=3
 interior=Room.new();room_layer.add_child(interior);interior.hide()
 room_ui=Control.new();room_ui.theme=ui.theme;room_ui.mouse_filter=Control.MOUSE_FILTER_IGNORE;room_layer.add_child(room_ui);room_ui.hide()
func make_button(parent:Node,text:String,action:Callable,height:int=42)->Button:
 var b:=Button.new();b.text=text;b.custom_minimum_size.y=height;b.pressed.connect(action);parent.add_child(b);return b
func line(text:String,size:int=18)->Label:
 var l:=Label.new();l.text=text;l.custom_minimum_size.x=475;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",maxi(16,size+state.text_size-20));body.add_child(l);return l
func open_dialog(id:String,title:String)->void:
 if not state.difficulty_chosen and id!="difficulty":return
 screen=id;fishing_running=false;player.stop();pending_npc="";pending_door=""
 for c in body.get_children():body.remove_child(c);c.queue_free()
 title_label.text=title;feedback.text="";feedback.modulate=Color.WHITE;close_button.disabled=false
 dialog.show();dialog.position=Vector2(704,140)
func close_dialog()->void:
 if screen=="difficulty" and not state.difficulty_chosen:return
 if screen=="guide" and not state.onboarded:finish_guide();return
 dialog.hide();fishing_running=false;get_viewport().gui_release_focus()
func message(text:String,good:bool=true)->void:
 feedback.text=text;feedback.modulate=Color("466635") if good else Color("a44c32")
func notify(text:String)->void:toast.text=text;toast.show();toast_timer=6.0
func save_game()->void:
 if persistence_enabled and not state.save_to(SAVE):notify("Không lưu được. Kiểm tra dung lượng và quyền ghi trên máy.")
func refresh_hud()->void:
 hud.text="Lv.%d • %d/3 việc  |  Cards %d  |  Powers %d"%[state.level,state.level_points(),state.cards,state.powers]
 if state.level==5:hud.text="Lv.5 • Hoàn thành chương thử  | Cards %d | Powers %d"%[state.cards,state.powers]
 bar.value=3 if state.level==5 else state.level_points()
func changed()->void:
 save_game();refresh_hud();update_world()
 if quest_level!=state.level:
  quest_level=state.level;notify("Lên cấp %d! +1 Power. Mở Tasks để xem khu vực và nhiệm vụ mới."%state.level)
func _process(delta:float)->void:
 elapsed+=delta
 player.locked=not state.onboarded or dialog.visible or interior.visible or state.delivery_active
 player.z_index=int(player.position.y)
 if toast_timer>0:
  toast_timer-=delta
  if toast_timer<=0:toast.hide()
 if pending_npc!="" and not dialog.visible:
  var n:=npc_by_id(pending_npc)
  if player.position.distance_to(n.at*2)<130:interact_npc(pending_npc)
 if pending_door!="" and not dialog.visible:
  var n:=npc_by_id(pending_door)
  if player.position.distance_to(n.door*2)<130:enter_room(pending_door)
 if state.delivery_active:tick_delivery(delta)
 if fishing_running:
  fishing_elapsed+=delta;fishing_position=fmod(fishing_elapsed*0.45,1.0)
  if is_instance_valid(fishing_slider):fishing_slider.value=fishing_position*100
 refresh_clock+=delta
 if refresh_clock>0.4:
  refresh_clock=0;refresh_crops();minimap.queue_redraw()
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
  if event.keycode==KEY_M:toggle_map();return
  if event.keycode==KEY_E and not dialog.visible and not interior.visible:
   var n:=nearest_npc()
   if not n.is_empty():interact_npc(n.id)
   return
 if not state.onboarded or dialog.visible or interior.visible or state.delivery_active:return
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
 if state.onboarded:map_panel.visible=not map_panel.visible
func show_difficulty()->void:
 open_dialog("difficulty","Welcome, Momo!");dialog.position=Vector2(370,100);close_button.disabled=true
 line("Chọn mức tiếng Anh trước khi bắt đầu. Đây là hồ sơ ngoại tuyến trên máy, không cần tài khoản.")
 for item in [["easy","Easy • A1–A2","Từ quen thuộc, câu ngắn, hướng dẫn từng bước."],["normal","Normal • B1–B2","Đọc tình huống và viết thư có giải thích."],["hard","Hard • C1","Từ nâng cao, suy luận và lập luận rõ ràng."]]:
  make_button(body,item[1],func():select_difficulty(item[0]),54);line(item[2],16)
 line("Có thể đổi trong Settings. Cấp độ thị trấn không bị giảm khi đổi độ khó.",16)
func select_difficulty(mode:String)->void:
 if state.choose_difficulty(mode):save_game();show_guide(0)
func show_guide(index:int)->void:
 if not state.difficulty_chosen:return
 guide_index=index;open_dialog("guide","Hướng dẫn • %d/6"%(index+1))
 var pages=[
 ["Bắt đầu từ một căn nhà nhỏ","WASD hoặc phím mũi tên để đi. Nhấp mặt đất để Momo tự đi tới. Nhấp NPC để đến nói chuyện, hoặc đứng gần và nhấn E. Nhấp biển cửa nhà để vào phòng. Esc hoặc × đóng nội dung."],
 ["Learn — học trước khi thử sức","Mở thẻ từ để học nghĩa Việt, giải thích Anh, phiên âm, trọng âm, cách dùng và ví dụ. Grammar có cấu trúc và cách dùng. Reading/Writing có hướng dẫn. Sau bước học, chọn Bắt đầu quiz. Sai thì đọc giải thích và thử lại."],
 ["Farm — biến kiến thức thành khu vườn","Đọc đúng 3 câu nhận 3 hạt. Plant: gieo một hạt vào ô trống. Water: tưới để cây không héo. Harvest: thu hoạch khi cây sẵn sàng. Bản thử cây lớn 20 giây, cần tưới trong 60 giây. Settings cho đổi sang12 giờ thực khi ruộng trống."],
 ["Letters, Settings và các nút khác","Letters: học cách viết, soạn thư, tự kiểm rồi gửi cho NPC. Settings: đổi độ khó, cỡ chữ, thời gian cây. Tasks: xem3 việc của cấp hiện tại. Map: bản đồ nhỏ góc phải, chấm cam là Momo. ? Help hoặc F1: mở lại hướng dẫn."],
 ["Làm gì để nhận được gì?","Từ mới đúng: +1 Word Card;3 từ/ngày: thêm3 cards. Bài đọc: hạt giống. Thu hoạch: cà rốt và cards. Giao3 cà rốt:8 cards,5 gỗ và tình bạn Mia. Powers dùng gợi ý. Hoàn thành mỗi nhiệm vụ làm đầy1/3 thanh cấp; đủ3 việc mở cấp tiếp theo và+1 Power."],
 ["Xe hàng, công cụ và nơi mới","Cấp2 có xe chở cà rốt đến Mia; chờ xe đến nơi mới nhận thưởng. Cấp3 mở Ben sửa nhà, Clara gửi/rút cards và Noah câu cá. Cấp4 mở vườn cây, áo mới và mua Powers. Những vùng phủ xanh chưa mở. Bấm Places trong Learn để học tên các địa điểm trước khi khám phá."]]
 line(pages[index][0],22);line(pages[index][1])
 if index>0:make_button(body,"← Trang trước",func():show_guide(index-1))
 if index<5:make_button(body,"Tiếp theo →",func():show_guide(index+1))
 else:make_button(body,"Bắt đầu chơi",finish_guide)
func finish_guide()->void:
 state.onboarded=true;dialog.hide();save_game();notify("Cấp1: học3 từ → đọc mở hạt → thu hoạch3 củ. Nhấn Tasks để theo dõi.")
func open_learning()->void:
 if not state.difficulty_chosen:return
 open_dialog("learn","Learn • Học và luyện tập")
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
 if all_seen:make_button(body,"Đã học3 từ • Bắt đầu quiz",func():mark_studied("vocabulary");start_quiz("vocabulary"))
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
 make_button(body,"Đã đọc hướng dẫn • Trả lời3 câu",func():mark_studied("reading");start_quiz("reading"))
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
 line("Đã nhận3 hạt giống nếu đây là lần hoàn thành đầu tiên ở mức này." if quiz_kind=="reading" else "Tiến trình đã lưu. Phần thưởng học từ được tính một lần; ôn có thưởng sau24 giờ.")
 make_button(body,"Xem nhiệm vụ tiếp theo",show_tasks)
func show_tasks()->void:
 open_dialog("tasks","Level %d • Mục tiêu hôm nay"%state.level)
 line("Mỗi việc đúng cấp tăng1/3 thanh tiến trình. Đủ3 việc tự lên cấp và nhận1 Power.")
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
  if state.level<2:message("Bài viết đã lưu; nhiệm vụ gửi thư mở ở cấp2.",false);return
  if writing.text.strip_edges().split(" ",false).size()<10:message("Hãy viết ít nhất10 từ để thực hành một thư ngắn.",false);return
  var first:bool=state.complete_task("letter")
  if first:state.cards+=3;state.friendship["emma"]=1
  changed();message("Emma đã nhận thư. +3 cards cho lần đầu. Đây là xác nhận luyện tập, không phải đánh giá chất lượng tiếng Anh."))
 make_button(body,"Xem cấu trúc và bài mẫu",show_writing_lesson)
func show_farm()->void:
 open_dialog("farm","Farm • Khu vườn nhỏ")
 line("Hạt: %d | Cà rốt: %d\nPlant = gieo • Water = tưới • Harvest = thu hoạch"%[state.seeds,state.produce],17)
 line("Thử nhanh: lớn20 giây; héo sau60 giây không tưới." if state.demo_mode else "Thời gian thực: lớn12 giờ; cần tưới trong12 giờ.",16)
 for i in range(6 if state.orchard_open else 3):
  var row:=HBoxContainer.new();body.add_child(row)
  var l:=Label.new();l.text="Ô%d • %s"%[i+1,state.crop_status(i,crop_time())];l.custom_minimum_size.x=165;row.add_child(l)
  for pair in [["Plant","plant"],["Water","water"],["Harvest","harvest"]]:make_button(row,pair[0],func():farm_action(pair[1],i),36)
 make_button(body,"Cập nhật tình trạng cây",show_farm)
 make_button(body,"Mua3 hạt • 3 cards",func():
  if state.unlocked.is_empty():message("Học và hoàn thành bài đọc để mở loại hạt trước.",false);return
  if state.cards<3:message("Cần3 cards. Học từ mới hoặc ôn từ đến hạn để nhận thẻ.",false);return
  state.cards-=3;state.seeds+=3;changed();show_farm();message("Đã mua3 hạt."))
 make_button(body,"Học hướng dẫn đọc để nhận hạt",show_reading)
func farm_action(action:String,index:int)->void:
 var ok:=false
 if index>=3 and not state.orchard_open:return
 match action:
  "plant":ok=state.plant(index,crop_time())
  "water":ok=state.water(index,crop_time())
  "harvest":ok=state.harvest(index,crop_time())>0
 changed();show_farm();refresh_crops()
 message("Xong! Harvest nhận1 cà rốt và2 cards." if ok and action=="harvest" else ("Đã thực hiện." if ok else "Kiểm tra hạt, tuổi cây hoặc hạn tưới. Ô héo có thể gieo lại."),ok)
func show_settings()->void:
 open_dialog("settings","Settings • Tùy chọn")
 line("Độ khó tiếng Anh",21)
 for mode in ["easy","normal","hard"]:
  make_button(body,mode.capitalize()+(" ✓" if state.difficulty==mode else ""),func():state.choose_difficulty(mode);changed();show_settings())
 line("Cỡ chữ",21)
 var slider:=HSlider.new();slider.min_value=16;slider.max_value=24;slider.step=1;slider.value=state.text_size;body.add_child(slider)
 slider.value_changed.connect(func(v):state.text_size=int(v);ui.theme.default_font_size=int(v);save_game();message("Cỡ chữ áp dụng khi mở lại nội dung."))
 var trial:=CheckButton.new();trial.text="Cây lớn nhanh20 giây (tắt =12 giờ)";trial.button_pressed=state.demo_mode;body.add_child(trial)
 trial.toggled.connect(func(on):
  for p in state.plots:
   if not p.is_empty():trial.set_pressed_no_signal(state.demo_mode);message("Hãy thu hoạch hoặc dọn hết cây trước khi đổi thời gian.",false);return
  state.demo_mode=on;changed())
 make_button(body,"Dọn các ô cây đã héo",func():
  for i in range(6):
   if state.crop_status(i,crop_time())=="wilted":state.plots[i]={}
  changed();refresh_crops();message("Đã dọn cây héo; từ đã học vẫn giữ nguyên."))
 line("Tự lưu trên máy. Không cần tài khoản. Không thu giọng nói. File tiến trình V3 riêng, bản cũ vẫn được giữ.",16)
func setup_people()->void:
 npc_data=[
 {"id":"home","name":"Momo","role":"Your home","relation":"Căn nhà và khu vườn đầu tiên của bạn.","place":"Farm — Nông trại","at":Vector2(200,690),"door":Vector2(190,680),"sprite":0,"level":1},
 {"id":"lily","name":"Lily","role":"Librarian / Thủ thư","relation":"Người hướng dẫn học tập của Momo.","place":"Library — Thư viện","at":Vector2(365,660),"door":Vector2(438,307),"sprite":0,"level":1},
 {"id":"tom","name":"Tom","role":"Farmer / Nông dân","relation":"Hàng xóm dạy Momo chăm vườn.","place":"Garden — Khu vườn","at":Vector2(440,640),"door":Vector2(450,650),"sprite":1,"level":1},
 {"id":"mia","name":"Mia","role":"Merchant / Chủ tiệm","relation":"Khách hàng đầu tiên của Momo.","place":"Market — Chợ","at":Vector2(920,580),"door":Vector2(961,600),"sprite":2,"level":2},
 {"id":"emma","name":"Emma","role":"Postal worker / Bưu tá","relation":"Bạn giúp Momo trao đổi thư từ.","place":"Post office — Bưu điện","at":Vector2(1090,751),"door":Vector2(1020,756),"sprite":0,"level":2},
 {"id":"ben","name":"Ben","role":"Carpenter / Thợ mộc","relation":"Người giúp Momo sửa nhà.","place":"Workshop — Xưởng mộc","at":Vector2(275,520),"door":Vector2(250,514),"sprite":1,"level":3},
 {"id":"clara","name":"Clara","role":"Banker / Nhân viên ngân hàng","relation":"Người giữ thẻ tiết kiệm cho Momo.","place":"Bank — Ngân hàng","at":Vector2(810,264),"door":Vector2(810,250),"sprite":2,"level":3},
 {"id":"noah","name":"Noah","role":"Fisher / Người câu cá","relation":"Bạn dạy Momo câu cá.","place":"Pier — Bến câu","at":Vector2(1340,781),"door":Vector2(1310,778),"sprite":1,"level":3}]
 for n in npc_data:
  if n.id!="home":
   var node:=Node2D.new();var v=art.animated("npcs",{"idle":[n.sprite,n.sprite+3]},62.0);node.add_child(v);v.play("idle")
   var label:=Label.new();label.text=n.name+"\n"+n.role;label.position=Vector2(-65,-105);label.add_theme_font_size_override("font_size",16)
   label.add_theme_color_override("font_color",Color("342b24"));label.add_theme_stylebox_override("normal",Style.box("f9edcd"));node.add_child(label)
   add_child(node);npc_nodes[n.id]=node
  var sign:=Label.new();sign.text=n.place+"\n[E / click] Enter";sign.position=n.door*2+Vector2(-65,0);sign.z_index=3000
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
 if state.level<n.level:notify("%s mở ở cấp%d."%[n.place,n.level]);return
 if id=="home":enter_room(id);return
 open_dialog("npc",n.name+" • "+str(n.role).split(" / ")[0])
 line(n.place,22);line(n.relation)
 line("Tình bạn: %d"%int(state.friendship.get(id,0)),16)
 match id:
  "lily":line("Mình sẽ giải thích kiến thức trước. Chọn chủ đề, học xong rồi thử sức nhé.");make_button(body,"Học cùng Lily",open_learning)
  "tom":line("Nhận hạt từ bài đọc, gieo rồi tưới. Thu hoạch3 củ sẽ giúp bạn hoàn thành cấp1.");make_button(body,"Chăm khu vườn",show_farm)
  "mia":
   line("Mình cần3 củ cà rốt. Xe hàng sẽ chở từ nông trại tới chợ; khi đến nơi bạn nhận8 cards,5 gỗ và tình bạn.")
   make_button(body,"Nhận đơn hàng",func():
    message("Đã nhận đơn! Chuẩn bị3 củ cà rốt." if state.accept_order() else "Đơn đã được nhận hoặc hoàn thành.");changed())
   make_button(body,"Chất hàng lên xe • 3 cà rốt",begin_delivery)
   if state.order_stage==2:make_button(body,"Xem cửa hàng mở rộng",show_shop)
  "emma":line("Hãy học cách viết thư, rồi viết một lời nhắn đủ ý. Mình sẽ nhận thư của bạn.");make_button(body,"Học viết thư",show_writing_lesson)
  "ben":
   line("5 gỗ đổi một lần sửa nhà: căn lều thành nhà có mái đẹp và thêm tủ đồ. Gỗ nhận từ đơn của Mia.")
   make_button(body,"Sửa nhà • 5 gỗ",func():var ok:bool=state.improve_home();changed();message("Nhà đã được nâng cấp! Về nhà để xem." if ok else "Cần5 gỗ hoặc bạn đã sửa nhà rồi.",ok))
  "clara":line("Bạn có thể gửi và rút Word Cards. Không có lãi, phí hoặc tiền thật.");make_button(body,"Mở sổ tiết kiệm",show_bank)
  "noah":line("Học3 từ: fish = cá; rod = cần câu; catch = bắt. Bấm Kéo khi kim nằm trong vùng40–70 để bắt cá.");make_button(body,"Thử câu cá",show_fishing)
 if id not in ["tom","noah"] and not (id=="lily" and state.level<2):make_button(body,"Vào "+str(n.place).split(" — ")[0],func():enter_room(id))
 make_button(body,"Học tên địa điểm",show_places)
func enter_room(id:String)->void:
 var n:=npc_by_id(id)
 if n.is_empty() or state.level<n.level:return
 if id=="lily" and state.level<2:notify("Thư viện mở cấp2. Lily đang đến nông trại dạy bạn.");return
 close_dialog();current_room=id;interior.kind=id;interior.upgraded=state.house_level>1;interior.queue_redraw();interior.show();room_ui.show()
 for c in room_ui.get_children():c.queue_free()
 var heading:=Label.new();heading.text=n.place+"  •  "+n.relation;heading.position=Vector2(210,96);room_ui.add_child(heading)
 var leave:=make_button(room_ui,"← Ra ngoài",leave_room);leave.position=Vector2(575,584);leave.size=Vector2(130,45)
 var avatar=art.sprite("momo",0,70);avatar.position=Vector2(645,548);room_ui.add_child(avatar)
 var actions:Array=[]
 match id:
  "home":actions=[["Bàn học • Learn",open_learning],["Viết thư ở bàn",show_writing],["Tủ đồ / nâng cấp",show_shop]]
  "lily":actions=[["Mở sách từ vựng",func():show_vocabulary(0)],["Đọc sách cùng Lily",show_reading]]
  "mia":actions=[["Quầy đơn hàng",func():interact_npc("mia")],["Mua vật phẩm",show_shop]]
  "emma":actions=[["Bàn viết thư",show_writing_lesson],["Soạn thư của bạn",show_writing]]
  "ben":actions=[["Bàn thợ mộc",func():interact_npc("ben")]]
  "clara":actions=[["Quầy gửi / rút",show_bank]]
  _:actions=[["Trò chuyện",func():interact_npc(id)]]
 for i in range(actions.size()):
  var b:=make_button(room_ui,actions[i][0],actions[i][1]);b.position=Vector2(290+i*240,300);b.size=Vector2(220,55)
func leave_room()->void:interior.hide();room_ui.hide();close_dialog()
func show_bank()->void:
 if state.level<3:notify("Ngân hàng mở ở cấp3.");return
 open_dialog("bank","Bank • Sổ tiết kiệm")
 line("Wallet: %d cards\nSavings: %d cards"%[state.cards,state.bank_balance],24)
 line("Deposit = gửi vào • Withdraw = rút ra. Chỉ là thẻ trong game; không lãi/phí.")
 for amount in [1,5]:
  make_button(body,"Deposit %d cards"%amount,func():var ok:bool=state.deposit(amount);changed();show_bank();message("Đã gửi thẻ." if ok else "Không đủ thẻ trong ví.",ok))
  make_button(body,"Withdraw %d cards"%amount,func():var ok:bool=state.withdraw(amount);changed();show_bank();message("Đã rút thẻ." if ok else "Không đủ thẻ tiết kiệm.",ok))
func show_fishing()->void:
 if state.level<3:notify("Bến câu mở ở cấp3.");return
 open_dialog("fishing","Fishing • Câu cá với Noah")
 line("Rod = cần câu • fish = cá • catch = bắt",20)
 line("1. Thả câu. 2. Quan sát kim chạy. 3. Bấm Kéo khi kim ở40–70. Đúng nhận1 cá,+3 cards; thưởng tối đa1 lần/ngày.")
 fishing_slider=ProgressBar.new();fishing_slider.max_value=100;fishing_slider.custom_minimum_size.y=32;body.add_child(fishing_slider)
 line("Vùng bắt cá: 40–70",21)
 make_button(body,"Thả câu",func():fishing_elapsed=0;fishing_running=true;message("Chờ kim vào khoảng40–70 rồi Kéo!"))
 make_button(body,"Kéo!",func():
  if not fishing_running:message("Hãy thả câu trước.",false);return
  fishing_running=false
  var in_zone:bool=fishing_position>=0.4 and fishing_position<=0.7
  var ok:bool=state.catch_fish(in_zone)
  changed();message("Bắt được cá! +3 cards." if ok else ("Hôm nay đã nhận thưởng câu cá; có thể tập lại." if in_zone else "Chưa đúng lúc. Thả câu và thử lại nhé."),ok))
func show_shop()->void:
 open_dialog("shop","Workshop & shop • Mở rộng")
 line("Các lựa chọn mở ở cấp4. Mỗi lựa chọn cần cards và chỉ hoàn thành nhiệm vụ cấp một lần.")
 if state.level<4:line("Hãy hoàn thành3 việc mỗi cấp. Hiện tại: cấp%d."%state.level);return
 for row in [["Mở vườn cây • 6 cards",state.expand_orchard],["Mũ mới • 4 cards",state.buy_outfit],["Mua1 Power • 3 cards",state.buy_power]]:
  make_button(body,row[0],func():var ok:bool=row[1].call();changed();message("Đã mở / mua thành công." if ok else "Không đủ cards hoặc vật phẩm đã sở hữu.",ok))
 if state.orchard_open:line("Vườn cây đã mở ở phía nam nông trại. 6 ô gieo trồng đã sẵn sàng.")
func build_world_objects()->void:
 var positions=[Vector2(209,712),Vector2(278,699),Vector2(358,684),Vector2(219,732),Vector2(291,720),Vector2(377,706)]
 for pos in positions:
  var node:=Node2D.new();node.position=pos*2;node.z_index=int(node.position.y);add_child(node);crop_nodes.append(node);crop_stages.append("")
 truck=load("res://game/scripts/journey_truck.gd").new();add_child(truck);truck.hide()
 if state.delivery_active:prepare_truck_route()
func prepare_truck_route()->void:
 truck_route=nav.find_path(Vector2(220,680)*2,Vector2(920,580)*2)
 if truck_route.is_empty():
  state.delivery_active=false;save_game();notify("Xe chưa tìm được đường. Hàng vẫn được giữ; thử lại.")
func begin_delivery()->void:
 if not state.start_delivery():message("Nhận đơn và chuẩn bị3 củ cà rốt trước; xe không nhận hai chuyến cùng lúc.",false);return
 player.stop();prepare_truck_route();close_dialog();changed();notify("Xe đang chở3 cà rốt tới chợ. Thưởng nhận khi xe đến nơi.")
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
  var ok:bool=state.finish_delivery();truck.hide();player.show();player.position=Vector2(920,580)*2;changed()
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
