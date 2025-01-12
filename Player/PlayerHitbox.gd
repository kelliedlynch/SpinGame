extends RigidHitbox
class_name PlayerHitbox

var max_speed = 2000
var last_frame_velocity: Vector2 = Vector2.ZERO

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
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.clamp(Vector2(-max_speed, -max_speed), Vector2(max_speed, max_speed))
	var test = move_and_collide(state.linear_velocity * state.step, true, .08, false)
	###print(state.transform)
	if test != null and test.get_collider() is DestructibleHitbox:
		#print("before ", state.linear_velocity)
		var destructor = $Destructor
		
		custom_integrator = true
		var destructible = test.get_collider().get_parent()
		var travel = test.get_travel()
		var dist = travel.length()
		var safe_dist = max(abs(dist) - destructible.material_max_cut_speed * state.step - 1, 0)
		
		var angle = travel.angle()
		var vec = Vector2.from_angle(angle)
		var safe_vec = safe_dist * vec
		#state.linear_velocity = safe_vec
		#var safe_x = max(abs(travel.x) - destructible.material_max_cut_speed - 1, 0)
		#var safe_y = max(abs(travel.y) - destructible.material_max_cut_speed - 1, 0)
		#safe_x *= -1 if travel.x < 0 else 1
		#safe_y *= -1 if travel.y < 0 else 1
		#state.integrate_forces()

		move_and_collide(safe_vec, false, .08, false)

		var max_speed = Vector2(destructible.material_max_cut_speed, destructible.material_max_cut_speed)
		
		state.linear_velocity -= state.linear_velocity * destructible.material_resistance
		state.linear_velocity = state.linear_velocity.clamp(-max_speed, max_speed)
		state.integrate_forces()

		#var safe_x = max(abs(dist.x) * .95, abs(dist.x) - 2)
		#var safe_y = max(abs(dist.y) * .95, abs(dist.y) - 2)
		#safe_x *= -1 if dist.x < 0 else 1
		#var safe_velocity = Vector2(safe_x, safe_y) / state.step
		#state.linear_velocity = safe_velocity
		#var max_cut = test.get_collider().get_parent().material_max_cut_speed
		#state.linear_velocity = safe_velocity.clamp(-Vector2(max_cut, max_cut), Vector2(max_cut, max_cut))
		#print("after ", state.linear_velocity)
		#move_and_collide(Vector2(safe_x, safe_y), false, .08, false)
		#linear_damp = destructible.material_linear_damp
		pass
	else:
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
	
func _physics_process(delta: float) -> void:
	if destructor.target != null:
		print(get_parent().cutting_power())
		pass
	if destructor.target != null and destructor.cut_state == destructor.CutState.CUTTING and get_parent().cutting_power() > destructor.target.material_hardness:
		destructor.target.apply_destructor(destructor)
		parent.spin_speed -= delta * (parent.spin_accel + destructor.target.material_resistance)

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
