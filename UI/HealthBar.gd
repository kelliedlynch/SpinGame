@tool
extends Node2D

@export var size: Vector2 = Vector2(120, 26)
@export var max_value: int = 100
@export var current_value: int = 100
@onready var back_left = $Background/bar_back_left
@onready var back_mid = $Background/bar_back_middle
@onready var back_right = $Background/bar_back_right
@onready var fill_left = $Fill/bar_fill_left
@onready var fill_mid = $Fill/bar_fill_middle
@onready var fill_right = $Fill/bar_fill_right

func _process(delta: float) -> void:
	var height = back_left.get_rect().size.y
	var bl_width = back_left.get_rect().size.x
	var back_width = size.x - bl_width * 2
	back_left.position = Vector2(bl_width / 2, height / 2)
	back_right.position = Vector2(bl_width / 2 + bl_width + back_width, height / 2)
	back_mid.position = Vector2(bl_width + back_width / 2, height / 2)
	back_mid.scale = Vector2(back_width / back_mid.get_rect().size.x, 1)
	var fl_width = fill_left.get_rect().size.x
	var fill_width = (float(current_value) / max_value) * size.x - fl_width * 2
	fill_left.position = Vector2(bl_width / 2, height / 2)
	fill_right.position = Vector2(bl_width / 2 + bl_width + fill_width, height / 2)
	fill_mid.position = Vector2(fl_width + fill_width / 2, height / 2)
	fill_mid.scale = Vector2(fill_width / fill_mid.get_rect().size.x, 1)
	
