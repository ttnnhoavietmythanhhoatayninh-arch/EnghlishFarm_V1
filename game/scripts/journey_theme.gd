extends RefCounted
static func box(color:String,border:String="a98250",radius:int=14)->StyleBoxFlat:
 var s:=StyleBoxFlat.new();s.bg_color=Color(color);s.border_color=Color(border)
 s.set_border_width_all(2);s.set_corner_radius_all(radius)
 s.content_margin_left=14;s.content_margin_right=14;s.content_margin_top=10;s.content_margin_bottom=10
 return s
static func make()->Theme:
 var t:=Theme.new();t.default_font_size=18
 for type in ["Label","Button","CheckButton","OptionButton","LineEdit","TextEdit","RichTextLabel"]:
  t.set_color("font_color",type,Color("3c4936"))
  t.set_color("font_hover_color",type,Color("25362c"))
  t.set_color("font_pressed_color",type,Color("25362c"))
  t.set_color("font_focus_color",type,Color("25362c"))
 t.set_stylebox("panel","PanelContainer",box("fff6df"))
 for type in ["Button","OptionButton"]:
  t.set_stylebox("normal",type,box("ebedce","afbb88",10))
  t.set_stylebox("hover",type,box("d8e5b9","738b53",10))
  t.set_stylebox("pressed",type,box("cad9a3","738b53",10))
  t.set_stylebox("disabled",type,box("e8e4d9","c9c3b3",10))
  t.set_stylebox("focus",type,box("dce7bc","526e3e",10))
  t.set_color("font_disabled_color",type,Color("77776b"))
 for type in ["LineEdit","TextEdit"]:
  t.set_stylebox("normal",type,box("fffdf4","bba784",7))
  t.set_stylebox("focus",type,box("fffdf4","71965c",7))
  t.set_color("caret_color",type,Color("394d32"))
  t.set_color("font_placeholder_color",type,Color("7d806c"))
 t.set_stylebox("background","ProgressBar",box("e4dec4","b9a879",7))
 t.set_stylebox("fill","ProgressBar",box("99b96d","7e9f55",7))
 t.set_color("font_color","ProgressBar",Color("253523"))
 return t
