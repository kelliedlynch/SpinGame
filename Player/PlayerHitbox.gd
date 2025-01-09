extends RigidHitbox
class_name PlayerHitbox

var max_speed = 2000
var last_frame_velocity: Vector2 = Vector2.ZERO

var needs_push = false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 3
	#body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	#collision_mask = 1 & 2
	
#func _on_body_entered(node):
	#if node is AnimatableBody2D:
		#node.add_collision_exception_with(self)
		#needs_push = true
#
func _on_body_exited(node):
	if node is AnimatableBody2D:
		#node.remove_collision_exception_with(self)
		pass
		##needs_push = true

func c (n): 
	n.add_collision_exception_with(self)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#print("linear velocity", linear_velocity, state.linear_velocity)
	#var test = move_and_collide(state.linear_velocity * state.step, true, .08, false)
	##print(state.transform)
	#if test != null and test.get_collider() is AnimatableBody2D:
		#call_deferred("c", test.get_collider())
		#pass
	
	
	#if needs_push == true:
		#state.linear_velocity += last_frame_velocity / 2
		#
		#needs_push = false
	#if get_contact_count() == 0:
		#last_frame_velocity = state.linear_velocity
		#pass
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.clamp(Vector2(-max_speed, -max_speed), Vector2(max_speed, max_speed))
	
func _physics_process(delta: float) -> void:
	var test = move_and_collide(linear_velocity * delta)
	#if test == true:
		#pass
	#last_frame_velocity = linear_velocity
	
	#var power = 100
	#state.apply_central_force(Vector2(-power, 0))
	#if Input.is_action_pressed("ui_left"):
		#state.linear_velocity += Vector2(-power, 0)
		##state.apply_central_force(Vector2(-power, 0))
	#if Input.is_action_pressed("ui_right"):
		#state.linear_velocity += Vector2(power, 0)
	#if Input.is_action_pressed("ui_up"):
		#state.linear_velocity += Vector2(0, -power)
	#if Input.is_action_pressed("ui_down"):
		#state.linear_velocity += Vector2(0, power)

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
	last_frame_velocity = linear_velocity
	var power = 100000
	if Input.is_action_pressed("ui_left"):
		#linear_velocity += Vector2(-power * delta, 0)
		apply_central_force(Vector2(-power * delta, 0))
	if Input.is_action_pressed("ui_right"):
		#linear_velocity += Vector2(power * delta, 0)
		apply_central_force(Vector2(power * delta, 0))
	if Input.is_action_pressed("ui_up"):
		#linear_velocity += Vector2(0, -power * delta)
		apply_central_force(Vector2(0, -power * delta))
	if Input.is_action_pressed("ui_down"):
		#linear_velocity += Vector2(0, power * delta)
		apply_central_force(Vector2(0, power * delta))
