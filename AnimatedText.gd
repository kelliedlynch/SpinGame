@tool
extends Node2D

@export var text: String
@export var font: Font
@export var font_size: int = 12

func _ready() -> void:
	font = get_parent().get_theme_default_font()

func _draw() -> void:
	var str_size = get_size()
	var pos = get_parent().get_rect().size / 2 
	position = pos
	draw_string(font, Vector2(-str_size.x / 2, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	
func get_size():
	font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
