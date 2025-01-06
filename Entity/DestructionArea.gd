extends Area2D
class_name DestructionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = true
	linear_damp = 100
	angular_damp = 100
	linear_damp_space_override = SPACE_OVERRIDE_REPLACE
	angular_damp_space_override = SPACE_OVERRIDE_REPLACE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
