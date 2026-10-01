extends Node2D
const State = preload("res://game/scripts/learning_state.gd")
const Art = preload("res://game/scripts/art.gd")
const Navigation = preload("res://game/scripts/farm_navigation.gd")
const SAVE := "user://englishfarm_learning_v1.json"
var state = State.new()
var art: RefCounted
var world: Texture2D
var content: Dictionary
var panel: PanelContainer
var hud: Label
var body: VBoxContainer
var status: Label
var page := "Learn"
var elapsed := 0.0
var warned := false
var inputs: Array[LineEdit] = []
var writing: TextEdit
var selected_word := 0
var persistence_enabled := true
@onready var player = $Momo
func _ready() -> void:
 for pair in [["move_left",KEY_LEFT],["move_right",KEY_RIGHT],["move_up",KEY_UP],["move_down",KEY_DOWN]]:
  var key := InputEventKey.new()
  key.physical_keycode = pair[1]
  if not InputMap.action_has_event(pair[0],key): InputMap.action_add_event(pair[0],key)
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 art = Art.new()
 world = load("res://game/assets/farm_spring.png")
 content = JSON.parse_string(FileAccess.get_file_as_string("res://data/learning_v1.json"))
 player.configure(art, Navigation.new())
 if persistence_enabled: state.load_from(SAVE)
 state.claim_login(now())
 var layer := CanvasLayer.new()
 add_child(layer)
 var bar := PanelContainer.new()
 bar.position = Vector2(20, 16)
 bar.size = Vector2(1220, 64)
 layer.add_child(bar)
 hud = Label.new()
 hud.add_theme_font_size_override("font_size",23)
 bar.add_child(hud)
 panel = PanelContainer.new()
 panel.position = Vector2(720, 96)
 panel.size = Vector2(520, 580)
 layer.add_child(panel)
 var margin := MarginContainer.new()
 for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,16)
 panel.add_child(margin)
 var outer := VBoxContainer.new()
 margin.add_child(outer)
 var tabs := HBoxContainer.new()
 outer.add_child(tabs)
 for title in ["Learn","Farm","Letters","Settings"]:
  button(tabs,title,func(): show_page(title))
 var scroll := ScrollContainer.new()
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.custom_minimum_size = Vector2(470, 430)
 outer.add_child(scroll)
 body = VBoxContainer.new()
 body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(body)
 status = Label.new()
 status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 status.custom_minimum_size.x = 460
 outer.add_child(status)
 var help := Label.new()
 help.position = Vector2(22, 680)
 help.text = "WASD / arrows: move | Click ground: walk | Wheel: zoom\nPrototype art • Learn words, unlock seeds, grow your farm."
 layer.add_child(help)
 show_page("Learn")
 save_progress()
func now() -> int: return int(Time.get_unix_time_from_system())
func save_progress() -> void:
 if persistence_enabled and not state.save_to(SAVE): status.text = "Could not save. Check disk space and permissions."
func _draw() -> void:
 if world: draw_texture_rect(world, Rect2(0,0,3072,2048),false)
func _process(delta: float) -> void:
 var focus := get_viewport().gui_get_focus_owner()
 player.locked = page == "Letters" or focus is LineEdit or focus is TextEdit
 elapsed += delta
 if elapsed >= 10800 and not warned:
  warned = true
  status.text = "You have played for 180 minutes. Take a break, stretch and rest your eyes."
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed:
  if event.button_index == MOUSE_BUTTON_LEFT: player.walk_to(get_global_mouse_position())
  elif event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
   var c: Camera2D = player.get_node("Camera2D")
   c.zoom = Vector2.ONE * clampf(c.zoom.x + (0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.1),0.45,1.8)
func button(parent: Node, text: String, action: Callable) -> Button:
 var b := Button.new()
 b.text = text
 b.custom_minimum_size.y = 38
 b.pressed.connect(action)
 parent.add_child(b)
 return b
func label(text: String) -> Label:
 var l := Label.new()
 l.text = text
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 l.custom_minimum_size.x = 450
 l.add_theme_font_size_override("font_size", state.text_size)
 body.add_child(l)
 return l
func refresh_hud() -> void:
 hud.text = "  EnglishFarm  |  Word Cards: %d  |  Powers: %d  |  Seeds: %d  |  %s" % [state.cards,state.powers,state.seeds,state.difficulty.to_upper()]
func show_page(title: String) -> void:
 page = title
 for child in body.get_children():
  body.remove_child(child)
  child.queue_free()
 inputs.clear()
 status.text = ""
 player.locked = title == "Letters"
 refresh_hud()
 if title == "Learn": show_learn()
 elif title == "Farm": show_farm()
 elif title == "Letters": show_letters()
 else: show_settings()
func lesson() -> Dictionary: return content[state.difficulty]
func show_learn() -> void:
 label("Vocabulary • recall before claiming")
 var words: Array = lesson().words
 selected_word %= words.size()
 var word: Dictionary = words[selected_word]
 label(word.definition)
 var answer := LineEdit.new()
 answer.placeholder_text = "Type the English word"
 body.add_child(answer)
 button(body,"Check word",func():
  if answer.text.strip_edges().to_lower() != word.word:
   status.text = "Try again. " + str(word.example)
   return
  var rewarded: bool = state.review_word(word.word,now()) if state.learned.has(word.word) else state.learn_word(word.word,now())
  status.text = "Correct! +1 Word Card (daily bonus may apply)." if rewarded else "Correct. This word's next rewarded review is due tomorrow."
  save_progress(); refresh_hud())
 button(body,"Next word",func(): selected_word += 1; show_page("Learn"))
 label("Reading • unlock 3 carrot seeds")
 label(lesson().passage)
 for q in lesson().questions:
  label(q.prompt)
  var field := LineEdit.new()
  field.placeholder_text = "Short answer"
  body.add_child(field)
  inputs.append(field)
 button(body,"Check reading",check_reading)
 button(body,"Use 1 Power: reading hints",func():
  if state.spend_power():
   status.text = "Hints: " + str(lesson().hint)
   save_progress();refresh_hud()
  else: status.text = "No Powers left. Return tomorrow for a login reward.")
 label("Optional grammar challenge • wrong answer costs 1 card")
 label(lesson().grammar.prompt)
 var grammar := LineEdit.new()
 body.add_child(grammar)
 button(body,"Check grammar",func():
  if now() < state.blocked_until:
   status.text = "Cooldown: %d seconds. Learn or review a word to unlock early." % (state.blocked_until-now());return
  var correct: bool = grammar.text.strip_edges().to_lower() == str(lesson().grammar.answer).to_lower()
  state.challenge(correct,now())
  status.text = "Correct! " + str(lesson().grammar.explanation) if correct else "Try again. " + str(lesson().grammar.explanation)
  save_progress();refresh_hud())
func check_reading() -> void:
 var score := 0
 for i in range(inputs.size()):
  if inputs[i].text.strip_edges().to_lower() in lesson().questions[i].answers: score += 1
 var unlocked: bool = state.unlock_seeds("carrot-"+state.difficulty,score,3)
 status.text = "3/3! You unlocked 3 seeds." if unlocked else "%d/3. Need all 3; each pack can be claimed once." % score
 save_progress();refresh_hud()
func show_farm() -> void:
 label("Carrot garden")
 label("Read to earn seeds. Plant, water within 12 hours, then harvest after 12 hours. Wilted plots can be replanted; learned words stay saved.")
 for i in range(6):
  label("Plot %d — %s" % [i+1,state.crop_status(i,now())])
  var row := HBoxContainer.new()
  body.add_child(row)
  button(row,"Plant",func(): farm_action("plant",i))
  button(row,"Water",func(): farm_action("water",i))
  button(row,"Harvest",func(): farm_action("harvest",i))
 button(body,"Refresh garden",func(): show_page("Farm"))
func farm_action(action: String, index: int) -> void:
 var ok := false
 if action == "plant": ok = state.plant(index,now())
 elif action == "water": ok = state.water(index,now())
 else: ok = state.harvest(index,now()) > 0
 save_progress()
 show_page("Farm")
 status.text = "Done." if ok else "Not available yet. Check seeds, crop age or watering deadline."
func show_letters() -> void:
 label("A letter for a neighbor")
 label(lesson().writing)
 writing = TextEdit.new()
 writing.custom_minimum_size = Vector2(450,180)
 writing.placeholder_text = "Write your reply here..."
 body.add_child(writing)
 label("Private practice: this draft stays in memory and is not sent anywhere.")
 button(body,"Show revision checklist",func():
  var n := writing.text.split(" ",false).size()
  status.text = "%d words. Check: greeting; answer every request; reasons/examples; verb tense; clear closing. This is a checklist, NOT AI or an IELTS/VSTEP score." % n)
func show_settings() -> void:
 label("Difficulty • content targets are provisional")
 var options := OptionButton.new()
 for title in ["Easy · A1–A2","Normal · B1–B2","Hard · C1"]: options.add_item(title)
 options.select(["easy","normal","hard"].find(state.difficulty))
 options.item_selected.connect(func(i): state.difficulty=["easy","normal","hard"][i];selected_word=0;save_progress();refresh_hud())
 body.add_child(options)
 label("Text size")
 var font_size := HSlider.new()
 font_size.min_value=16;font_size.max_value=28;font_size.step=1;font_size.value=state.text_size
 font_size.value_changed.connect(func(v): state.text_size=int(v);save_progress())
 body.add_child(font_size)
 label("Text size applies when you reopen a tab. Offline local save. No account, microphone or paid AI service. Login Powers increase to 7/day. Prototype daily target: 3 new words.")
 button(body,"Save progress",func():save_progress();status.text="Progress saved locally.")
