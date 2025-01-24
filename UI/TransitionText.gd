@tool
extends Node2D

@export var transition_text: String

func _draw() -> void:
	var font = get_parent().get_theme_default_font()
	var str_size = font.get_string_size(transition_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 160)
	var pos = get_parent().get_rect().size / 2 
	position = pos
	draw_string(font, Vector2(-str_size.x / 2, 0), transition_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 160)
