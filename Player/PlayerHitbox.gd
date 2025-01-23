extends RigidHitbox
class_name PlayerHitbox

var input_vector := Vector2.ZERO
var destructor: Destructor

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

#func _on_destroyed_destructible(node):
	#if destructor.target == node:
		#destructor.cut_state = Destructor.CutState.READY
		#destructor.target = null

#func _try_clip_destructible(state: PhysicsDirectBodyState2D) -> bool:
	#if destructor.target == null:
		#return false
	#var destructible = destructor.target
	#var power = destructor.get_power()
	#if destructor.cut_state == Destructor.CutState.CUTTING or destructor.cut_state == Destructor.CutState.BEGIN_CUT:
		#power += destructible.CUT_INERTIA
	#if power < destructible.material_hardness:
		#return false
	#var material_limited_velocity = state.linear_velocity.limit_length(destructible.material_max_cut_speed)
	#var travel = material_limited_velocity * state.step
	#var next_frame_shape = destructor.get_next_frame_destructor(travel)
	#var destructor_hit = destructible.apply_destructor(next_frame_shape)
	#return destructor_hit

#func _apply_destructible_forces(state: PhysicsDirectBodyState2D):
	#if destructor.target == null:
		#return
	#var destructible = destructor.target
	#state.linear_velocity.limit_length(state.linear_velocity.length() - destructible.material_linear_damp)
	#state.linear_velocity = state.linear_velocity.limit_length(destructible.material_max_cut_speed)
func _apply_destructible_forces(state: PhysicsDirectBodyState2D):
	if destructor.target == null:
		return
	state.linear_velocity.limit_length(state.linear_velocity.length() - destructor.target.material_linear_damp)
	state.linear_velocity = state.linear_velocity.limit_length(destructor.target.material_max_cut_speed)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	destructor._integrate_forces(state)
	_apply_destructible_forces(state)
	#if destructor.cut_state == Destructor.CutState.BEGIN_CUT:
		#var clip = _try_clip_destructible(state)
		#_apply_destructible_forces(state)
		#if clip == true:
			#destructor.cut_state = Destructor.CutState.CUTTING
		#else:
			#destructor.cut_state = Destructor.CutState.END_CUT
	#elif destructor.cut_state == Destructor.CutState.CUTTING:
		#var clip = _try_clip_destructible(state)
		#_apply_destructible_forces(state)
		#if clip == false:
			#destructor.cut_state = Destructor.CutState.END_CUT
	#elif destructor.cut_state == Destructor.CutState.END_CUT:
		#var clip = _try_clip_destructible(state)
		#_apply_destructible_forces(state)
		#if clip == false:
			#if destructor.target != null:
				#for child in destructor.target.get_parent().get_children():
					#if child == destructor.target:
						#continue
					##child.remove_collision_exception_with(self)
				#destructor.target.tree_exiting.disconnect(_on_destroyed_destructible)
				#destructor.target = null
			#destructor.cut_state = Destructor.CutState.READY
		#else:
			#destructor.cut_state = Destructor.CutState.CUTTING

	
func _physics_process(delta: float) -> void:
	linear_velocity += input_vector
	input_vector = Vector2.ZERO
	linear_velocity = linear_velocity.limit_length(Player.max_move_speed)
	
	if destructor.cut_state == Destructor.CutState.READY:
		var test = move_and_collide(linear_velocity * delta, true, .08, true)
		if test != null and test.get_collider() is DestructibleHitbox:
			var destructible = test.get_collider()
			if destructor.get_power() >= destructible.material_hardness:
				destructor.cut_state = Destructor.CutState.BEGIN_CUT
				destructor.target = destructible
	elif destructor.cut_state == Destructor.CutState.BEGIN_CUT:
		pass
	elif destructor.cut_state == Destructor.CutState.CUTTING:
		pass
	elif destructor.cut_state == Destructor.CutState.END_CUT:
		pass
	elif destructor.cut_state == Destructor.CutState.NOT_READY:
		pass
