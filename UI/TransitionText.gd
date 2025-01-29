@tool
extends Node2D
class_name TransitionText

@export var text: String = "Text"
@export var font_size: int = 100
@export var outline: int = 0
@export var font: Font

func _draw() -> void:
	var parent = get_parent()
	#var pos = Vector2.ZERO
	if parent is Control:
		font = parent.get_theme_default_font()
		position = get_parent().get_rect().size / 2 
	else:
		font = get_tree().root.get_theme_default_font()
	var str_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(-str_size.x / 2, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	if outline > 0:
		draw_string_outline(font, Vector2(-str_size.x / 2, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, outline, Color.BLACK)
