extends RigidHitbox
class_name PlayerHitbox

var max_speed = 2000
var begin_cut_speed = 0

var needs_push = false

var input_vector := Vector2.ZERO


@onready var parent: Player = get_parent()
@onready var destructor: Destructor = $Destructor
@onready var visible_area: VisibleArea = $VisibleArea

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
	destructor.cut_state = destructor.CutState.READY
	node.was_destroyed.disconnect(_on_destroyed_destructible)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity += input_vector
	input_vector = Vector2.ZERO
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)

	if destructor.cut_state == destructor.CutState.READY:
		var test = move_and_collide(state.linear_velocity * state.step, true, .08, true)
		if test != null and test.get_collider() is DestructibleHitbox:
			#custom_integrator = true
			var destructible = test.get_collider().get_parent()
			if destructor.cutting_power() >= destructible.material_hardness + destructible.CUT_INERTIA:
				destructor.cut_state = destructor.CutState.BEGIN_CUT
				destructible.was_destroyed.connect(_on_destroyed_destructible)
				destructible.hitbox.add_collision_exception_with(self)
				destructor.target = destructible
				begin_cut_speed = state.linear_velocity.length()
				apply_central_impulse(-test.get_remainder())
				state.integrate_forces()
				pass
			#else:
				#custom_integrator = false
		#else:
			#custom_integrator = false
	elif destructor.cut_state == destructor.CutState.BEGIN_CUT:
		destructor.cut_state = destructor.CutState.CUTTING
		var destructible = destructor.target
		if destructible == null:
			destructor.cut_state = destructor.CutState.READY
			return
		begin_cut_speed -= destructible.material_linear_damp
		var material_limited_velocity = state.linear_velocity.limit_length(begin_cut_speed)
		state.linear_velocity = material_limited_velocity
		var travel = state.linear_velocity * state.step
		var next_frame_shape = destructor.get_next_frame_destructor(travel)
		var destructor_hit = destructible.apply_destructor(next_frame_shape)
		if destructor_hit == false:
			destructor.cut_state = destructor.CutState.END_CUT
	elif destructor.cut_state == destructor.CutState.CUTTING:
		var destructible = destructor.target
		if destructible == null:
			destructor.cut_state = destructor.CutState.READY
			return
		begin_cut_speed -= destructible.material_linear_damp
		var material_limited_velocity = state.linear_velocity.limit_length(begin_cut_speed)
		state.linear_velocity = material_limited_velocity
		var travel = state.linear_velocity * state.step
		var next_frame_shape = destructor.get_next_frame_destructor(travel)
		var destructor_hit = destructible.apply_destructor(next_frame_shape)
		if destructor_hit == false:
			destructor.cut_state = destructor.CutState.END_CUT
	elif destructor.cut_state == destructor.CutState.END_CUT:
		var destructible = destructor.target
		if destructible == null:
			destructor.cut_state = destructor.CutState.READY
			return
		begin_cut_speed -= destructible.material_linear_damp
		var material_limited_velocity = state.linear_velocity.limit_length(begin_cut_speed)
		state.linear_velocity = material_limited_velocity
		var travel = state.linear_velocity * state.step
		var next_frame_shape = destructor.get_next_frame_destructor(travel)
		var destructor_hit = destructible.apply_destructor(next_frame_shape)
		if destructor_hit == true:
			destructor.cut_state = destructor.CutState.CUTTING
		else:
			destructor.cut_state = destructor.CutState.READY
			destructible.was_destroyed.disconnect(_on_destroyed_destructible)
			destructible.hitbox.remove_collision_exception_with(self)
			if material_limited_velocity.length() < begin_cut_speed:
				state.linear_velocity = state.linear_velocity.limit_length(begin_cut_speed)
				begin_cut_speed = 0
				destructor.target = null
	
	#if destructor.cut_state == destructor.CutState.CUTTING:
		#custom_integrator = true
		#var destructible = destructor.target
		#var speed = min(state.linear_velocity.length(), destructible.material_max_cut_speed)
		#var material_limited_velocity = state.linear_velocity.limit_length(speed - destructible.material_linear_damp)
		#state.linear_velocity = material_limited_velocity
		#begin_cut_speed -= destructible.material_linear_damp
		#if destructor.cutting_power() >= destructible.material_hardness - destructible.CUT_INERTIA:
			#var travel = state.linear_velocity * state.step
			#var next_frame_shape = destructor.get_next_frame_destructor(travel)
			#var destructor_hit = destructible.apply_destructor(next_frame_shape)
			##print("destroyed any of destructible: ", destructor_hit)
			#var a = destructible.hitbox.get_collision_exceptions()
			#if destructor_hit == false:
				#destructor.cut_state == destructor.CutState.READY
				#destructible.hitbox.remove_collision_exception_with(destructor)
				#if material_limited_velocity.length() < begin_cut_speed:
					#state.linear_velocity = state.linear_velocity.limit_length(begin_cut_speed)
				#begin_cut_speed = 0
				#destructor.target = null
			#else:
				#move_and_collide(travel)
	#pass


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
