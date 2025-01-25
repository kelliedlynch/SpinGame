extends RigidHitbox
class_name PlayerHitbox

var destructor: Destructor

var queued_force: Vector2 = Vector2.ZERO

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	lock_rotation = true
	collision_mask = CollisionLayer.PLAYER_HITBOX + CollisionLayer.ENEMY_HITBOX
	
func _on_body_exited(node):
	if node is AnimatableBody2D:
		pass

func _on_body_entered(node):
	if node is AnimatableBody2D:
		pass

func _apply_destructible_forces(state: PhysicsDirectBodyState2D):
	if destructor.target == null:
		return
	state.linear_velocity.limit_length(state.linear_velocity.length() - destructor.target.destructible_material.linear_damp)
	state.linear_velocity = state.linear_velocity.limit_length(destructor.target.destructible_material.max_cut_speed)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if queued_force != Vector2.ZERO:
		state.linear_velocity = queued_force
		queued_force = Vector2.ZERO
	destructor._integrate_forces(state)
	_apply_destructible_forces(state)
	
func _physics_process(delta: float) -> void:
	if destructor.cut_state == Destructor.CutState.READY:
		var test = move_and_collide(linear_velocity * delta, true, .08, true)
		if test != null:
			var collider = test.get_collider()
			if collider is DestructibleHitbox:
				var destructible = collider
				if destructor.get_power() >= destructible.destructible_material.begin_cut_threshold:
					destructor.cut_state = Destructor.CutState.BEGIN_CUT
					destructor.target = destructible
			elif collider is BossHeart:
				collider.get_parent().controller.take_damage(destructor.get_power())
				pass
	elif destructor.cut_state == Destructor.CutState.BEGIN_CUT:
		pass
	elif destructor.cut_state == Destructor.CutState.CUTTING:
		pass
	elif destructor.cut_state == Destructor.CutState.END_CUT:
		pass
	elif destructor.cut_state == Destructor.CutState.NOT_READY:
		pass
