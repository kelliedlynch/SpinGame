@tool
extends Node2D
class_name PlayerEntity

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $Hitbox
@onready var destructor: PlayerDestructor = $Hitbox/Destructor
@onready var blade_sprite: Polygon2D = $Hitbox/saw_blade_coll/base_sprite
@onready var googly_eyes: Node2D = $Hitbox/GooglyEyes
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var charge_sparks: CPUParticles2D = $Hitbox/charge_sparks
@onready var charge_glow: Sprite2D = $Hitbox/charge_glow
@onready var audio: Node = $AudioManager

var _move_state: MoveState = MoveState.MOVING
var move_state: MoveState:
	get:
		return _move_state
	set(value):
		emit_signal("move_state_changed", _move_state, value)
		_move_state = value
signal move_state_changed

var invincible_blink: Tween

var input_vector := Vector2.ZERO:
	set(value):
		if value != input_vector:
			input_vector_changed.emit(input_vector, value)
			input_vector = value
signal input_vector_changed

var spin_spark_threshold: float = .9

var dash_cooldown: float = 1
var dash_cooldown_percent: float = 0:
	set(value):
		dash_cooldown_changed.emit(value)
		dash_cooldown_percent = value
var dash_charge_time: float = .2
var dash_duration: float = 1.5
var dash_speed = 1.8
var dash_tween: Tween
var dash_charge_angle: float
var dash_charge_indicator: Line2D
signal dash_ready
signal dash_cooldown_changed

@export var sprite_texture: Texture2D:
	set(value):
		sprite_texture = value
		_on_sprite_changed(value)

func _on_sprite_changed(tex: Texture2D):
	if hitbox == null: return
	var shape = hitbox.get_node("saw_blade_coll")
	if shape == null:
		shape = CollisionPolygon2D.new()
		shape.name = "saw_blade_coll"
		hitbox.add_child(shape)
		shape.owner = self
	else:
		for child in shape.get_children():
			child.free()
	var sprite = Polygon2D.new()
	sprite.texture = tex
	
	var polys = PolygonMath.polygons_from_texture(tex)
	assert(polys.size() == 1)
	shape.polygon = polys[0]
	sprite.polygon = polys[0]
	sprite.name = "base_sprite"
	#shape.base_sprite = sprite
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var offset = sprite.texture.get_size() / 2
	sprite.offset = -offset
	sprite.texture_offset = offset
	sprite.position = offset
	blade_sprite = sprite
	sprite.scale = scale
	shape.scale = Vector2.ONE
	shape.call_deferred("add_child", sprite)
	#shape.position = -sprite.texture.get_size() / 2
	#sprite.owner = self
	sprite.set_deferred("owner", self)

var spin_curve: Curve = load("res://Component/Destructor/PlayerSpinCurve.tres")

func _ready() -> void:
	#BattleOverlay.transition_finished.connect(_on_transition_finished)
	move_state_changed.connect(_on_move_state_changed)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	googly_eyes.hitbox = hitbox
	destructor.hitbox = hitbox
	hitbox.destructor = destructor
	#z_index = RenderLayer.ARENA_ENTITIES
	#z_as_relative = false
	_on_sprite_changed(sprite_texture)
	move_state_changed.connect(audio._on_move_state_changed)
	destructor.cut_state_changed.connect(audio._on_cut_state_changed)
	if Engine.is_editor_hint() == true:
		#charge_glow.visible = true
		set_process_input(false)
	_begin_dash_cooldown()

func _on_invincible_state_changed(new_val: bool):
	if new_val == true:
		invincible_blink = create_tween()
		invincible_blink.tween_property(blade_sprite, "modulate:a", .1, .1)
		invincible_blink.tween_property(blade_sprite, "modulate:a", .7, .1)
		invincible_blink.set_loops(200)
	else:
		invincible_blink.stop()
		blade_sprite.modulate.a = 1

func _on_take_damage(dmg: int):
	animation.play("hurt")

func _input(event: InputEvent):
	if event.is_action_pressed("gameplay_begin_dash") and dash_cooldown_percent >= 100:
		if move_state != MoveState.DASH_CHARGING:
			move_state = MoveState.DASH_CHARGING
	elif event.is_action_released("gameplay_begin_dash"):
		if move_state == MoveState.DASH_CHARGING:
			move_state = MoveState.DASHING

		
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() == true: return
	hitbox.linear_velocity += input_vector
	input_vector = Vector2.ZERO
	if move_state == MoveState.DASHING:
		hitbox.linear_velocity = hitbox.linear_velocity.limit_length(Player.max_move_speed * dash_speed)
	else:
		hitbox.linear_velocity = hitbox.linear_velocity.limit_length(Player.max_move_speed)

	
func _process(delta: float) -> void:
	var r = spin_curve.sample(destructor.spin_speed / destructor.max_spin_speed) * delta
	$Hitbox/saw_blade_coll/base_sprite.rotate(-r)
	#hitbox.rotate_sprite(-r)
	
	if is_processing_input() == true:
		var power = Player.move_power
		if Input.is_action_pressed("gameplay_move_left"):
			if move_state == MoveState.DASH_CHARGING:
				dash_charge_angle -= delta * 3.6
			else:
				input_vector += Vector2(-power * delta, 0)
		if Input.is_action_pressed("gameplay_move_right"):
			if move_state == MoveState.DASH_CHARGING:
				dash_charge_angle += delta * 3.6
			else:
				input_vector += Vector2(power * delta, 0)
		if Input.is_action_pressed("gameplay_move_up"):
			if move_state == MoveState.DASH_CHARGING:
				dash_charge_angle -= delta * 3.6
			else:
				input_vector += (Vector2(0, -power * delta))
		if Input.is_action_pressed("gameplay_move_down"):
			if move_state == MoveState.DASH_CHARGING:
				dash_charge_angle += delta * 3.6
			else:
				input_vector += (Vector2(0, power * delta))

		if move_state == MoveState.DASHING:
			input_vector += Vector2.from_angle(dash_charge_angle) * power * delta
				
		if dash_charge_indicator != null:
			var indicator_length = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2
			dash_charge_indicator.points[1] = Vector2.from_angle(dash_charge_angle) * indicator_length + dash_charge_indicator.points[0] 
			
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
	if curr == MoveState.MOVING and dash_tween == null:
		_begin_dash_cooldown()
		
	if curr == MoveState.DASH_CHARGING:
		_begin_dash_charge()
	if prev == MoveState.DASH_CHARGING and curr == MoveState.MOVING:
		_end_dash_charge()
	if prev == MoveState.DASH_CHARGING and curr == MoveState.DASHING:
		_begin_dash()
	if prev == MoveState.DASHING and curr == MoveState.MOVING:
		_end_dash()

func _begin_dash_cooldown():
	dash_tween = create_tween()
	dash_tween.tween_property(self, "dash_cooldown_percent", 100, dash_cooldown)
	dash_tween.tween_callback(dash_ready.emit)

#TODO: fix timing and cleanup on dash charge stuff; indicator line should be removed if dash is 
#		canceled, and new dash shouldn't start if mouse is clicked while space is down

func _begin_dash_charge():
	destructor.spin_state = PlayerDestructor.SpinState.DASH_CHARGE
	if dash_tween: dash_tween.kill()
	dash_tween = create_tween()
	dash_tween.tween_property(destructor, "spin_speed", destructor.max_spin_speed, dash_charge_time)
	dash_charge_angle = hitbox.linear_velocity.angle()
	hitbox.linear_velocity = Vector2.ZERO
	var indicator_length = max(get_viewport_rect().size.x, get_viewport_rect().size.y) * 2
	dash_charge_indicator = Line2D.new()
	dash_charge_indicator.width = 100
	dash_charge_indicator.add_point(to_global(hitbox.position))
	dash_charge_indicator.add_point(Vector2.from_angle(dash_charge_angle) * indicator_length + dash_charge_indicator.points[0])
	var c = Color.KHAKI
	c.a = .2
	dash_charge_indicator.modulate = c
	dash_charge_indicator.z_index = RenderLayer.ARENA_BACKGROUND
	Player.arena.add_child(dash_charge_indicator)
	
func _end_dash_charge():
	if dash_tween: dash_tween.kill()
	if dash_charge_indicator != null:
		dash_charge_indicator.queue_free()
		
func _begin_dash():
	if dash_tween: dash_tween.kill()
	if dash_charge_indicator != null:
		dash_charge_indicator.queue_free()
	destructor.spin_state = PlayerDestructor.SpinState.DASHING
	dash_tween = create_tween()
	dash_tween.tween_property(self, "dash_cooldown_percent", 0, .2)
	dash_tween.tween_interval(dash_duration)
	dash_tween.tween_callback(set.bind("move_state", MoveState.MOVING))
	
	hitbox.linear_velocity = Vector2.from_angle(dash_charge_angle) * Player.max_move_speed * dash_speed

func _end_dash():
	destructor.spin_state = PlayerDestructor.SpinState.DEFAULT
	_begin_dash_cooldown()
	
func _exit_tree() -> void:
	if dash_charge_indicator != null:
		dash_charge_indicator.queue_free()
	
enum MoveState {
	MOVING,
	DASH_CHARGING,
	DASHING
}
