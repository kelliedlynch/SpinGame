extends Node2D
class_name PlayerEntity

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $Hitbox
@onready var destructor: Destructor = $Hitbox/Destructor
@onready var blade_sprite: Polygon2D = $Hitbox/saw_blade_coll/saw_blade_vis
@onready var googly_eyes: Node2D = $Hitbox/GooglyEyes
@onready var animation: AnimationPlayer = $AnimationPlayer

var move_state: MoveState = MoveState.MOVING
var dash_ready_max: float = 1
var dash_ready_curr: float = 0
var dash_charge_max: float = .7
var dash_charge_curr: float = 0
var dash_duration: float = 1
var dash_speed = 1.25

func _ready() -> void:
	googly_eyes.hitbox = hitbox
	destructor.hitbox = hitbox
	hitbox.destructor = destructor
	z_index = RenderLayer.ARENA_ENTITIES


func _on_take_damage(dmg: int):
	animation.play("hurt")

func _input(event: InputEvent):
	if event.is_action_pressed("gameplay_begin_dash"):
		move_state = MoveState.DASH_CHARGING
		print("dash charge begin")
	elif event.is_action_released("gameplay_begin_dash"):
		move_state = MoveState.DASHING
		print("dash charge end")

	
func _process(delta: float) -> void:
	var r = destructor.spin_speed * delta
	blade_sprite.rotate(-r)
	
	var power = Player.move_power
	if Input.is_action_pressed("ui_left"):
		hitbox.input_vector += (Vector2(-power * delta, 0))
	if Input.is_action_pressed("ui_right"):
		hitbox.input_vector += (Vector2(power * delta, 0))
	if Input.is_action_pressed("ui_up"):
		hitbox.input_vector += (Vector2(0, -power * delta))
	if Input.is_action_pressed("ui_down"):
		hitbox.input_vector += (Vector2(0, power * delta))
	
enum MoveState {
	MOVING,
	DASH_CHARGING,
	DASHING
}
