@tool
extends Node2D

@export var text: String = "Text"
@export var font_size: int = 100

func _draw() -> void:
	var font = get_parent().get_theme_default_font()
	var str_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var pos = get_parent().get_rect().size / 2 
	position = pos
	draw_string(font, Vector2(-str_size.x / 2, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
