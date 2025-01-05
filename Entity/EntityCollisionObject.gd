extends RigidBody2D


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for i in state.get_contact_count():
		print(self, state.get_contact_collider_position(i))
