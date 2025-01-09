extends Area2D
class_name DestructibleArea

func _ready() -> void:
	monitoring = true
	linear_damp = 10
	linear_damp_space_override = SPACE_OVERRIDE_COMBINE
