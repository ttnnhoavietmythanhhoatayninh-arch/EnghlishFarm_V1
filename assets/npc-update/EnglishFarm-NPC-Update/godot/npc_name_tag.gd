# npc_name_tag.gd — Godot 4.x (CHƯA chạy thử trong dự án thật, hãy test trước khi dùng)
# Tên nổi trên đầu NPC, KHÔNG nằm trong textbox/hội thoại.
# Cách dùng: thêm Node2D làm con của node NPC, gắn script này, đặt npc_name / name_color / head_y.
extends Node2D
class_name NpcNameTag

@export var npc_name: String = "Noah"
@export var name_color: Color = Color("#7EC8FF")
@export var head_y: float = -100.0          # y đỉnh đầu so với chân NPC (đơn vị local của NPC, số âm)
@export var gap_px: float = 6.0             # khoảng cách tên – đỉnh đầu (pixel màn hình)
@export var font_size: int = 18             # cỡ chữ trên màn hình, không nên < 14
@export var outline_px: int = 5
@export var keep_screen_size: bool = true   # giữ cỡ chữ cố định khi camera zoom / NPC bị scale
@export var hide_during_dialog: bool = true

var _label: Label

func _ready() -> void:
	z_as_relative = false
	z_index = 100                           # luôn nằm trên nhân vật, cây, nhà
	position = Vector2(0, head_y)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", name_color)
	_label.add_theme_color_override("font_outline_color", Color("#2B1B12"))
	_label.add_theme_constant_override("outline_size", outline_px)
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(_label)
	set_npc_name(npc_name)

func set_npc_name(n: String) -> void:
	npc_name = n
	if _label == null:
		return
	_label.text = n
	var sz := _label.get_minimum_size()
	_label.size = sz
	_label.position = Vector2(-sz.x * 0.5, -gap_px - sz.y)   # căn giữa, nằm ngay trên đầu

func set_dialog_open(open: bool) -> void:   # gọi từ hệ thống hội thoại nếu muốn ẩn tên khi đang nói chuyện
	visible = not (hide_during_dialog and open)

func _process(_dt: float) -> void:
	if not keep_screen_size:
		return
	var cam := get_viewport().get_camera_2d()
	var parent := get_parent() as Node2D
	if cam == null or parent == null:
		return
	scale = Vector2.ONE / (parent.global_scale * cam.zoom)
