extends AnimatableBody2D
class_name DestructibleHitbox

func _ready() -> void:
	collision_layer = 2
	#collision_mask = 2
	pass

func _on_hitbox_entered(node):
	pass

func _physics_process(delta: float) -> void:
	pass
