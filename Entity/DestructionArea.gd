extends Area2D
class_name DestructionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = true
	linear_damp = 30
	angular_damp = 30
	#linear_damp_space_override = SPACE_OVERRIDE_REPLACE
	#angular_damp_space_override = SPACE_OVERRIDE_REPLACE
