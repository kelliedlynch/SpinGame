extends RigidHitbox
class_name PlayerHitbox

var max_speed = 2000
var begin_cut_speed = 0

var needs_push = false

var input_vector := Vector2.ZERO

var destructor: Destructor

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	body_exited.connect(_on_body_exited)
	lock_rotation = true
	collision_mask = 1 | 2
#
func _on_body_exited(node):
	if node is AnimatableBody2D:
		pass

func _on_destroyed_destructible(node):
	if destructor.target == node:
		#destructor.set_deferred("cut_state", Destructor.CutState.READY)
		destructor.cut_state = Destructor.CutState.READY
		destructor.target = null
	else:
		pass

func _try_clip_destructible(state: PhysicsDirectBodyState2D) -> bool:
	if destructor.target == null:
		return false
	var destructible = destructor.target
	var power = destructor.get_power()
	if destructor.cut_state == Destructor.CutState.CUTTING:
		power += destructible.CUT_INERTIA
	if power < destructible.material_hardness:
		return false
	var material_limited_velocity = state.linear_velocity.limit_length(destructible.material_max_cut_speed)
	#state.linear_velocity = material_limited_velocity
	var travel = material_limited_velocity * state.step
	var next_frame_shape = destructor.get_next_frame_destructor(travel)
	var destructor_hit = destructible.apply_destructor(next_frame_shape)
	#if destructor_hit:
		#destructible.generate_fragment(destructor, next_frame_shape)
		
	return destructor_hit

func _apply_destructible_forces(state: PhysicsDirectBodyState2D):
	if destructor.target == null:
		return
	var destructible = destructor.target
	state.linear_velocity.limit_length(state.linear_velocity.length() - destructible.material_linear_damp)
	#var a = state.linear_velocity.length()
	#var b = destructor.target.material_max_cut_speed
	state.linear_velocity = state.linear_velocity.limit_length(destructible.material_max_cut_speed)
	destructor.spin_speed -= destructible.material_resistance
	#return state

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#state.linear_velocity += input_vector
	#input_vector = Vector2.ZERO
	#state.linear_velocity = state.linear_velocity.limit_length(max_speed)

	if destructor.cut_state == Destructor.CutState.BEGIN_CUT:
		var clip = _try_clip_destructible(state)
		_apply_destructible_forces(state)
		if clip == true:
			#destructor.cut_state = Destructor.CutState.END_CUT
			destructor.cut_state = Destructor.CutState.CUTTING
		else:
			destructor.cut_state = Destructor.CutState.END_CUT
	elif destructor.cut_state == Destructor.CutState.CUTTING:
		var clip = _try_clip_destructible(state)
		_apply_destructible_forces(state)
		if clip == false:
			destructor.cut_state = Destructor.CutState.END_CUT
	elif destructor.cut_state == Destructor.CutState.END_CUT:
		var clip = _try_clip_destructible(state)
		#_apply_destructible_forces(state)
		if clip == false:
			if destructor.target != null:
				for child in destructor.target.get_parent().get_children():
					if child == destructor.target:
						continue
					#child.remove_collision_exception_with(self)
				destructor.target.tree_exiting.disconnect(_on_destroyed_destructible)
				destructor.target = null
			destructor.cut_state = Destructor.CutState.READY
		else:
			destructor.cut_state = Destructor.CutState.CUTTING

	
func _physics_process(delta: float) -> void:
	linear_velocity += input_vector
	input_vector = Vector2.ZERO
	linear_velocity = linear_velocity.limit_length(max_speed)
	
	if destructor.cut_state == Destructor.CutState.READY:
		var test = move_and_collide(linear_velocity * delta, true, .08, true)
		if test != null and test.get_collider() is DestructibleHitbox:
			var destructible = test.get_collider()
			#var destructible_shape: SGCollPoly = test.get_collider_shape()
			if destructor.get_power() >= destructible.material_hardness + destructible.CUT_INERTIA:
				destructor.cut_state = Destructor.CutState.BEGIN_CUT
				for child in destructible.get_parent().get_children():
					if child == destructible:
						continue
					#child.add_collision_exception_with(self)
				destructible.tree_exiting.connect(_on_destroyed_destructible.bind(destructible))
				destructor.target = destructible
	elif destructor.cut_state == Destructor.CutState.BEGIN_CUT:
		pass
	elif destructor.cut_state == Destructor.CutState.CUTTING:
		pass
	elif destructor.cut_state == Destructor.CutState.END_CUT:
		#if destructor.target != null:
			#destructor.target.tree_exiting.disconnect(_on_destroyed_destructible)
		#destructor.target = null
		#destructor.cut_state = Destructor.CutState.READY
		pass
	elif destructor.cut_state == Destructor.CutState.NOT_READY:
		pass

func _process(delta) -> void:
	#last_frame_velocity = linear_velocity
	#get_parent().linear_velocity = linear_velocity
	var power = 1000
	if Input.is_action_pressed("ui_left"):
		#linear_velocity += Vector2(-power * delta, 0)
		input_vector += (Vector2(-power * delta, 0))
	if Input.is_action_pressed("ui_right"):
		#linear_velocity += Vector2(power * delta, 0)
		input_vector += (Vector2(power * delta, 0))
	if Input.is_action_pressed("ui_up"):
		#linear_velocity += Vector2(0, -power * delta)
		input_vector += (Vector2(0, -power * delta))
	if Input.is_action_pressed("ui_down"):
		#linear_velocity += Vector2(0, power * delta)
		input_vector += (Vector2(0, power * delta))
		
