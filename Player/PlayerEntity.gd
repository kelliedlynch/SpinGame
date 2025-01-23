extends Node2D
class_name PlayerEntity

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $Hitbox
@onready var destructor: PlayerDestructor = $Hitbox/Destructor
@onready var blade_sprite: Polygon2D = $Hitbox/saw_blade_coll/saw_blade_vis
@onready var googly_eyes: Node2D = $Hitbox/GooglyEyes
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var charge_sparks: CPUParticles2D = $Hitbox/charge_sparks
@onready var charge_glow: Sprite2D = $Hitbox/charge_glow

var _move_state: MoveState = MoveState.MOVING
var move_state: MoveState:
	get:
		return _move_state
	set(value):
		emit_signal("move_state_changed", _move_state, value)
		_move_state = value
signal move_state_changed



var spin_spark_threshold: float = .9

var dash_ready_max: float = 1
var dash_ready_curr: float = 0
var dash_charge_max: float = .7
var dash_charge_curr: float = 0
var dash_duration: float = 1.5
var dash_speed = 1.5
var dash_tween: Tween
var dash_charge_angle: float
var dash_charge_indicator: Line2D

var spin_curve: Curve = load("res://Component/Destructor/PlayerSpinCurve.tres")

func _ready() -> void:
	move_state_changed.connect(_on_move_state_changed)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	googly_eyes.hitbox = hitbox
	destructor.hitbox = hitbox
	hitbox.destructor = destructor
	z_index = RenderLayer.ARENA_ENTITIES


func _on_take_damage(dmg: int):
	animation.play("hurt")

func _input(event: InputEvent):
	if event.is_action_pressed("gameplay_begin_dash"):
		move_state = MoveState.DASH_CHARGING
	elif event.is_action_released("gameplay_begin_dash"):
		if move_state == MoveState.DASH_CHARGING:
			move_state = MoveState.DASHING

		

	

	
func _process(delta: float) -> void:
	var r = spin_curve.sample(destructor.spin_speed / destructor.max_spin_speed) * delta
	blade_sprite.rotate(-r)
	
	
	var power = Player.move_power
	if Input.is_action_pressed("ui_left"):
		if move_state == MoveState.DASH_CHARGING:
			dash_charge_angle -= delta * 3.6
		else:
			hitbox.input_vector += Vector2(-power * delta, 0)
	if Input.is_action_pressed("ui_right"):
		if move_state == MoveState.DASH_CHARGING:
			dash_charge_angle += delta * 3.6
		else:
			hitbox.input_vector += Vector2(power * delta, 0)
	if Input.is_action_pressed("ui_up"):
		if move_state == MoveState.DASH_CHARGING:
			dash_charge_angle -= delta * 3.6
		else:
			hitbox.input_vector += (Vector2(0, -power * delta))
	if Input.is_action_pressed("ui_down"):
		if move_state == MoveState.DASH_CHARGING:
			dash_charge_angle += delta * 3.6
		else:
			hitbox.input_vector += (Vector2(0, power * delta))

	if move_state == MoveState.DASHING:
		hitbox.input_vector += Vector2.from_angle(dash_charge_angle) * power * delta
			
	if dash_charge_indicator != null:
		var indicator_length = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2
		dash_charge_indicator.points[1] = Vector2.from_angle(dash_charge_angle) * indicator_length
		
	if destructor.spin_speed > destructor.max_spin_speed * .9:
		charge_sparks.emitting = true
		charge_glow.visible = true
	else:
		charge_sparks.emitting = false
		charge_glow.visible = false
	if charge_sparks.emitting:
		charge_sparks.rotate(r/3)
		
func _on_hitbox_body_entered(node):
	if move_state == MoveState.DASH_CHARGING:
		if node is AnimatableBody2D:
			move_state = MoveState.MOVING

func _on_move_state_changed(prev: MoveState, curr: MoveState):
	if curr == MoveState.DASH_CHARGING:
		_begin_dash_charge()
	if prev == MoveState.DASH_CHARGING and curr == MoveState.MOVING:
		_end_dash_charge()
	if prev == MoveState.DASH_CHARGING and curr == MoveState.DASHING:
		_begin_dash()
	if prev == MoveState.DASHING and curr == MoveState.MOVING:
		_end_dash()

func _begin_dash_charge():
	destructor.spin_state = PlayerDestructor.SpinState.DASH_CHARGE
	if dash_tween: dash_tween.kill()
	dash_tween = create_tween()
	dash_tween.tween_property(destructor, "spin_speed", destructor.max_spin_speed, .2)
	dash_charge_angle = hitbox.linear_velocity.angle()
	hitbox.linear_velocity = Vector2.ZERO
	var indicator_length = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2
	dash_charge_indicator = Line2D.new()
	dash_charge_indicator.width = 100
	dash_charge_indicator.add_point(to_global(hitbox.position))
	dash_charge_indicator.add_point(Vector2.from_angle(dash_charge_angle) * indicator_length)
	var c = Color.KHAKI
	c.a = .2
	dash_charge_indicator.modulate = c
	dash_charge_indicator.z_index = RenderLayer.ARENA_BACKGROUND
	Player.arena.add_child(dash_charge_indicator)
	
func _end_dash_charge():
	if dash_tween: dash_tween.kill()
	if dash_charge_indicator:
		dash_charge_indicator.queue_free()
		
func _begin_dash():
	if dash_tween: dash_tween.kill()
	if dash_charge_indicator:
		dash_charge_indicator.queue_free()
	destructor.spin_state = PlayerDestructor.SpinState.DASHING
	dash_tween = create_tween()
	dash_tween.tween_interval(dash_duration)
	dash_tween.tween_callback(set.bind("move_state", MoveState.MOVING))
	hitbox.linear_velocity = Vector2.from_angle(dash_charge_angle) * Player.max_move_speed * dash_speed

func _end_dash():
	destructor.spin_state = PlayerDestructor.SpinState.DEFAULT
	
enum MoveState {
	MOVING,
	DASH_CHARGING,
	DASHING
}
