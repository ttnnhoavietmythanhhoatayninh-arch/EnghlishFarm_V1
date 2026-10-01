extends "res://game/scripts/learning_main.gd"
const TownState=preload("res://game/scripts/town_state.gd")
const TownNav=preload("res://game/scripts/town_navigation.gd")
const TOWN_SAVE="user://englishfarm_town_v2.json"
const NPCS=[
 {"id":"lily","name":"Lily - Librarian","at":Vector2(438,307),"sprite":0,"page":"Learn","message":"Welcome! Read the seed note and remember three new words."},
 {"id":"tom","name":"Tom - Farmer","at":Vector2(480,580),"sprite":1,"page":"Farm","message":"Read to unlock seeds. Water your plants and bring three carrots to Mia."},
 {"id":"mia","name":"Mia - Merchant","at":Vector2(920,580),"sprite":2,"page":"Town","message":"I need three carrots for the market. Can you help?"},
 {"id":"ben","name":"Ben - Carpenter","at":Vector2(275,520),"sprite":1,"page":"Town","message":"Bring five wood from Mia's order and I can upgrade your tools."},
 {"id":"emma","name":"Emma - Post Office","at":Vector2(1090,751),"sprite":0,"page":"Letters","message":"Write a reply to your neighbor. Your draft stays on this device."},
 {"id":"noah","name":"Noah - Fisher","at":Vector2(1340,781),"sprite":1,"page":"Town","message":"The river is peaceful. Fishing is planned for a later version."}]
const PLOTS=[Vector2(209,712),Vector2(219,732),Vector2(278,699),Vector2(291,720),Vector2(358,684),Vector2(377,706)]
var garden_nodes:Array[Node2D]=[]
var garden_stages:Array[String]=[]
var map_panel:PanelContainer
var update_timer:=0.0
var proximity:Label
func _ready()->void:
 state=TownState.new()
 var keep:=persistence_enabled
 persistence_enabled=false
 super._ready()
 persistence_enabled=keep
 if keep:state.load_from(TOWN_SAVE)
 state.claim_login(now())
 world=load("res://game/assets/town.png")
 player.navigation=TownNav.new()
 player.position=Vector2(780,560)*2
 player.get_node("Camera2D").zoom=Vector2.ONE*0.72
 for npc in NPCS:
  var n:=Node2D.new()
  n.position=npc.at*2
  n.z_index=int(n.position.y)
  var v=art.animated("npcs",{"idle":[npc.sprite,npc.sprite+3]},70.0)
  n.add_child(v);v.play("idle")
  var caption:=Label.new()
  caption.text=npc.name
  caption.position=Vector2(-75,-102)
  caption.add_theme_font_size_override("font_size",18)
  caption.add_theme_color_override("font_shadow_color",Color.BLACK)
  caption.add_theme_constant_override("shadow_offset_x",2)
  caption.add_theme_constant_override("shadow_offset_y",2)
  n.add_child(caption);add_child(n)
 for pos in PLOTS:
  var n:=Node2D.new();n.position=pos*2;n.z_index=int(n.position.y)
  add_child(n);garden_nodes.append(n);garden_stages.append("")
 var layer:=CanvasLayer.new();add_child(layer)
 var row:=HBoxContainer.new();row.position=Vector2(20,90);layer.add_child(row)
 button(row,"Town / Quests",func():show_page("Town"))
 button(row,"Map [M]",toggle_map)
 button(row,"Close [Esc]",close_panel)
 proximity=Label.new();proximity.position=Vector2(20,135)
 proximity.add_theme_font_size_override("font_size",20)
 layer.add_child(proximity)
 build_map(layer)
 show_page("Town")
 status.text="Welcome to EnglishFarm Town! Start with Mia's carrot order."
 refresh_hud();refresh_garden();save_progress();queue_redraw()
func crop_time()->int:
 return int(Time.get_unix_time_from_system()*2160.0) if state.demo_mode else now()
func save_progress()->void:
 if persistence_enabled and not state.save_to(TOWN_SAVE) and is_instance_valid(status):status.text="Could not save progress."
func _process(delta:float)->void:
 super._process(delta)
 player.locked=panel.visible or (is_instance_valid(map_panel) and map_panel.visible)
 player.z_index=int(player.position.y)
 update_timer+=delta
 if update_timer>=0.5:
  update_timer=0
  refresh_garden()
  if is_instance_valid(proximity):
   var n:=nearest_npc()
   proximity.text="[E] Talk to "+str(NPCS[n].name) if n>=0 else "Explore the town - [E] talk - [M] map"
func nearest_npc()->int:
 var nearest:=-1
 var distance:=140.0
 for i in range(NPCS.size()):
  var d:float=player.position.distance_to(NPCS[i].at*2)
  if d<distance:distance=d;nearest=i
 return nearest
func _unhandled_input(event:InputEvent)->void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE:close_panel();map_panel.hide();return
  var focus:=get_viewport().gui_get_focus_owner()
  if focus is LineEdit or focus is TextEdit:return
  if event.keycode==KEY_M:toggle_map();return
  if event.keycode==KEY_E and nearest_npc()>=0:
   var npc:Dictionary=NPCS[nearest_npc()]
   show_page(npc.page);status.text=npc.name+": "+npc.message;return
 if panel.visible or (is_instance_valid(map_panel) and map_panel.visible):return
 super._unhandled_input(event)
func close_panel()->void:
 panel.hide();player.locked=false;get_viewport().gui_release_focus()
func show_page(title:String)->void:
 super.show_page(title if title!="Town" else "Settings")
 panel.show()
 if title=="Town":
  page="Town"
  for c in body.get_children():body.remove_child(c);c.queue_free()
  show_town()
func refresh_hud()->void:
 if not state is TownState:super.refresh_hud();return
 hud.text="  EnglishFarm Town | Cards %d | Powers %d | Seeds %d | Carrots %d | %s"%[state.cards,state.powers,state.seeds,state.produce,"TRIAL 20s" if state.demo_mode else "REAL TIME"]
func show_town()->void:
 label("Welcome to EnglishFarm Town")
 label("1. Accept Mia's order. 2. Visit Lily: read and unlock seeds. 3. Plant and harvest 3 carrots. 4. Deliver to Mia. 5. Upgrade at Ben's workshop.")
 label("Order: "+["Available","Bring 3 carrots","Completed"][state.order_stage])
 button(body,"Accept carrot order",func():state.accept_order();save_progress();show_page("Town"))
 button(body,"Deliver 3 carrots (+8 cards, +5 wood)",func():
  var ok:bool=state.deliver_order();save_progress();show_page("Town")
  status.text="Thank you! Mia friendship +1." if ok else "Accept the order and harvest three carrots first.")
 button(body,"Upgrade tools (5 wood)",func():
  var ok:bool=state.upgrade_tools();save_progress();show_page("Town")
  status.text="Tool level 2 unlocked. Cosmetic progression in this demo." if ok else "Need 5 wood; maximum demo level is 2.")
 label("Wood: %d | Tool level: %d | Mia friendship: %d"%[state.wood,state.tool_level,int(state.friendship.get("mia",0))])
 for dest in ["Learn","Farm","Letters","Settings"]:button(body,dest,func():show_page(dest))
 button(body,"Explore town",close_panel)
func show_farm()->void:
 label("Momo's garden")
 label("Trial: grow in 20 seconds, water within 60 seconds." if state.demo_mode else "Real time: grow in 12 hours, water within 12 hours.")
 for i in range(6):
  label("Plot %d - %s"%[i+1,state.crop_status(i,crop_time())])
  var row:=HBoxContainer.new();body.add_child(row)
  button(row,"Plant",func():farm_action("plant",i))
  button(row,"Water",func():farm_action("water",i))
  button(row,"Harvest",func():farm_action("harvest",i))
 button(body,"Refresh garden",func():show_page("Farm"))
 button(body,"Buy 3 more seeds (3 cards)",func():
  if state.unlocked.is_empty():status.text="Complete a reading lesson first.";return
  if state.cards<3:status.text="Need 3 Word Cards.";return
  state.cards-=3;state.seeds+=3;save_progress();refresh_hud();status.text="Bought 3 seeds.")
func farm_action(action:String,index:int)->void:
 var ok:=false
 if action=="plant":ok=state.plant(index,crop_time())
 elif action=="water":ok=state.water(index,crop_time())
 else:ok=state.harvest(index,crop_time())>0
 save_progress();show_page("Farm");refresh_garden()
 status.text="Done." if ok else "Check seeds, crop age or watering deadline."
func refresh_garden()->void:
 for i in range(garden_nodes.size()):
  var stage:String=state.crop_status(i,crop_time())
  if stage==garden_stages[i]:continue
  garden_stages[i]=stage
  for c in garden_nodes[i].get_children():c.queue_free()
  if stage!="empty":
   var v=art.sprite("items",1 if stage=="growing" else 3,45.0)
   v.modulate=Color("82725b") if stage=="wilted" else (Color("8ecf78") if stage=="growing" else Color.WHITE)
   v.scale*=0.55 if stage=="growing" else 1.0
   garden_nodes[i].add_child(v)
func show_letters()->void:
 super.show_letters()
 writing.text=state.letter_draft
 writing.text_changed.connect(func():state.letter_draft=writing.text.left(10000);save_progress())
 for c in body.get_children():
  if c is Label and c.text.begins_with("Private practice"):c.text="Draft saved locally. No text is sent to an AI service."
func show_settings()->void:
 super.show_settings()
 if not state is TownState:return
 var toggle:=CheckButton.new();toggle.text="Trial garden: 20 seconds (otherwise 12 hours)";toggle.button_pressed=state.demo_mode
 body.add_child(toggle)
 toggle.toggled.connect(func(on):
  for p in state.plots:
   if not p.is_empty():toggle.set_pressed_no_signal(state.demo_mode);status.text="Harvest or clear all plots before changing time mode.";return
  state.demo_mode=on;save_progress();refresh_hud())
 button(body,"Clear wilted plots",func():
  for i in range(6):
   if state.crop_status(i,crop_time())=="wilted":state.plots[i]={}
  save_progress();refresh_garden();status.text="Wilted plots cleared.")
func build_map(layer:CanvasLayer)->void:
 map_panel=PanelContainer.new();map_panel.position=Vector2(170,80);map_panel.size=Vector2(900,600);layer.add_child(map_panel)
 var base:=Control.new();base.custom_minimum_size=Vector2(900,600);map_panel.add_child(base)
 var texture:=TextureRect.new();texture.texture=world;texture.size=Vector2(900,600);texture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;texture.mouse_filter=Control.MOUSE_FILTER_IGNORE;base.add_child(texture)
 for npc in NPCS:
  var b:=Button.new();b.text=str(npc.name).split(" - ")[0];b.position=npc.at*Vector2(900.0/1536.0,600.0/1024.0)
  b.pressed.connect(func():map_panel.hide();close_panel();player.walk_to(npc.at*2))
  base.add_child(b)
 map_panel.hide()
func toggle_map()->void:
 map_panel.visible=not map_panel.visible
 if map_panel.visible:panel.hide();player.stop()
