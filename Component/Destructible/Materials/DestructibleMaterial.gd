@tool
extends Resource
class_name DestructibleMaterial

@export var texture: Texture2D:
	set(value):
		texture = value
		changed.emit(self)
@export var begin_cut_threshold: float
@export var end_cut_threshold: float
@export var resistance: float
@export var max_cut_speed: float
@export var linear_damp: float
