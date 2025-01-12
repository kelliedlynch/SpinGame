extends RigidHitbox
class_name PlayerHitbox

var max_speed = 2000
var begin_cut_velocity: Vector2 = Vector2.ZERO

var needs_push = false

var input_vector := Vector2.ZERO


@onready var parent: Player = get_parent()
@onready var destructor: Destructor = $Destructor

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 3
	#body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	lock_rotation = true

#
func _on_body_exited(node):
	if node is AnimatableBody2D:
		pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity += input_vector
	input_vector = Vector2.ZERO
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)
		
	if destructor.cut_state == destructor.CutState.NOT_READY:
		pass
	
	var test = move_and_collide(state.linear_velocity * state.step, true, .08, false)
	###print(state.transform)
	if test != null and test.get_collider() is DestructibleHitbox:
		#print("before ", state.linear_velocity)
		custom_integrator = true
		var destructible = test.get_collider().get_parent()
		var travel = test.get_travel()
		var dist = travel.length()
		var safe_dist = max(abs(dist) - destructible.material_max_cut_speed * state.step - 1, 0)
		
		var angle = travel.angle()
		var vec = Vector2.from_angle(angle)
		var safe_vec = safe_dist * vec
		move_and_collide(safe_vec, false, .08, false)
		
		if destructor.cut_state == destructor.CutState.READY:
			# TODO: see if inertia needs to apply to stopping cuts, too
			var cut_threshold = destructible.material_hardness + destructible.CUT_INERTIA
			if destructor.cutting_power() >= cut_threshold:
				destructor.cut_state = destructor.CutState.CUTTING
				destructor.target = destructible
				begin_cut_velocity = state.linear_velocity
		
		if destructor.cut_state == destructor.CutState.CUTTING:
			var destructed = destructor.apply_destructor_to_destructible(destructible)
			destructible.update_destructed(destructed)
			destructor.spin_speed -= destructible.material_resistance
			begin_cut_velocity = begin_cut_velocity.limit_length(begin_cut_velocity.length() - destructible.material_linear_damp)
			var material_limited_velocity = state.linear_velocity.limit_length(destructible.material_max_cut_speed)
			state.linear_velocity = material_limited_velocity if material_limited_velocity.length() < begin_cut_velocity.length() else begin_cut_velocity
			
		state.linear_velocity =state.linear_velocity.limit_length(max_speed)
		state.integrate_forces()

		pass
	else:
		destructor.cut_state = destructor.CutState.READY
		begin_cut_velocity = Vector2.ZERO
		custom_integrator = false
		#if test.get_collider() is DestructibleHitbox:
			##state.total_linear_damp = test.get_collider().get_parent().linear_damp
			#state.linear_velocity = state.linear_velocity.clamp(Vector2(-100, -100), Vector2(100, 100))
		#call_deferred("c", test.get_collider())
		#pass
	
	
	#if needs_push == true:
		#state.linear_velocity += last_frame_velocity / 2
		#
		#needs_push = false
	#if get_contact_count() == 0:
		#last_frame_velocity = state.linear_velocity
		#pass
	#if state.linear_velocity.length() > max_speed:
		#state.linear_velocity = state.linear_velocity.clamp(Vector2(-max_speed, -max_speed), Vector2(max_speed, max_speed))
	#if get_contact_count() == 0:
		#get_parent().linear_velocity = state.linear_velocity
	#get_parent().linear_velocity = state.linear_velocity
	
#func _physics_process(delta: float) -> void:
	#if destructor.target != null:
		#print(destructor.cutting_power())
		#pass
	#if destructor.target != null and destructor.cut_state == destructor.CutState.CUTTING and destructor.cutting_power() > destructor.target.material_hardness:
		#destructor.apply_destructor_to_destructible(destructor.target)
		#parent.spin_speed -= delta * (parent.spin_accel + destructor.target.material_resistance)

#func _input(event: InputEvent) -> void:
	#var power = 1000
	#if event.is_action_pressed("ui_left"):
		##linear_velocity += Vector2(-power, 0)
		#apply_central_force(Vector2(-power, 0))
	#if Input.is_action_pressed("ui_right"):
		#linear_velocity += Vector2(power, 0)
	#if Input.is_action_pressed("ui_up"):
		#linear_velocity += Vector2(0, -power)
	#if Input.is_action_pressed("ui_down"):
		#linear_velocity += Vector2(0, power)

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
