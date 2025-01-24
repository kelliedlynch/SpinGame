extends RigidBody2D
class_name BossHeart

@onready var sprite: Polygon2D = $heart_collision_poly/heart_visible_poly
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _revealed: bool = false
var revealed: bool:
	get:
		return _revealed
	set(value):
		emit_signal("revealed_changed", _revealed, value)
		_revealed = value
signal revealed_changed

var hidden_color: Color = Color.MISTY_ROSE
var revealed_color: Color = Color.INDIAN_RED

func _ready() -> void:
	revealed_changed.connect(_on_revealed_changed)
	sprite.modulate = hidden_color

func _on_body_entered(node: Node2D):
	if node is PlayerHitbox:
		get_parent().controller.deal_damage(node.destructor.get_power())
		animation_player.stop()
		animation_player.play("HeartAnimations/hurt")
		animation_player.animation_set_next("HeartAnimations/hurt", "HeartAnimations/heartbeat")

func _on_revealed_changed(_old, new_val):
	if new_val == true:
		sprite.modulate = revealed_color
		collision_layer = CollisionLayer.ENEMY_HITBOX
		collision_mask = CollisionLayer.ENEMY_HITBOX
		animation_player.play("HeartAnimations/heartbeat")
