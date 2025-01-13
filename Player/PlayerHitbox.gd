extends RigidHitbox
class_name PlayerHitbox

var max_speed = 2000
var begin_cut_velocity: Vector2 = Vector2.ZERO

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
#
func _on_body_exited(node):
	if node is AnimatableBody2D:
		pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity += input_vector
	input_vector = Vector2.ZERO
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)

	var test = move_and_collide(state.linear_velocity * state.step, true, .08, true)
	###print(state.transform)
	if test != null and test.get_collider() is DestructibleHitbox:
		#print("before ", state.linear_velocity)
		custom_integrator = true
		var destructible = test.get_collider().get_parent()
		
		if destructor.cut_state == destructor.CutState.READY:
			var cut_threshold = destructible.material_hardness + destructible.CUT_INERTIA
			if destructor.cutting_power() >= cut_threshold:
				destructor.cut_state = destructor.CutState.CUTTING
				destructor.target = destructible
				begin_cut_velocity = state.linear_velocity
			else:
				custom_integrator = false
		
		if destructor.cut_state == destructor.CutState.CUTTING:
			if destructor.cutting_power() >= destructible.material_hardness - destructible.CUT_INERTIA:
				print(begin_cut_velocity.length())
				var travel = test.get_travel()
				var dist = travel.length()
				#var safe_dist = max(abs(dist) - destructible.material_max_cut_speed * state.step - 1, 0)
				
				var angle = travel.angle()
				var vec = Vector2.from_angle(angle)
				#var safe_vec = safe_dist * vec
				move_and_collide(travel.limit_length(dist - 1), false, .08, false)
				begin_cut_velocity = begin_cut_velocity.limit_length(begin_cut_velocity.length() - destructible.material_linear_damp)
				var material_limited_velocity = state.linear_velocity.limit_length(destructible.material_max_cut_speed)
				var next_frame_shape = destructor.get_next_frame_destructor(material_limited_velocity, state.step)
				var destructed = destructor.apply_destructor_to_destructible(destructible, next_frame_shape)
				destructible.update_destructed(destructed)
				
				
				state.linear_velocity = material_limited_velocity if material_limited_velocity.length() < begin_cut_velocity.length() else begin_cut_velocity
				state.linear_velocity = state.linear_velocity.limit_length(max_speed)
				state.integrate_forces()
				return
			else:
				#move_and_collide(state.linear_velocity * state.step)
				destructor.cut_state = destructor.CutState.READY
				var exit_speed = max(destructor.target.material_max_cut_speed, begin_cut_velocity.length())
				state.linear_velocity = Vector2.from_angle(state.linear_velocity.angle()) * exit_speed
				begin_cut_velocity = Vector2.ZERO
				custom_integrator = false
	elif test == null and destructor.cut_state == destructor.CutState.CUTTING:
		destructor.cut_state = destructor.CutState.READY
		var exit_speed = max(destructor.target.material_max_cut_speed, begin_cut_velocity.length())
		state.linear_velocity = Vector2.from_angle(state.linear_velocity.angle()) * exit_speed
		begin_cut_velocity = Vector2.ZERO
		custom_integrator = false


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
