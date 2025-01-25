extends AnimatableBody2D
class_name BossHeart

@onready var sprite: Polygon2D = $SGCollisionPoly/base_sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _revealed: bool = false
var revealed: bool:
	get:
		return _revealed
	set(value):
		heart_revealed_changed.emit(value)
		_revealed = value
signal heart_revealed_changed

var hidden_color: Color = Color.DIM_GRAY
var revealed_color: Color = Color.INDIAN_RED

func _ready() -> void:
	sprite.modulate = hidden_color

func _on_dealt_damage():
	#if node is PlayerHitbox:
		#get_parent().controller.deal_damage(node.destructor.get_power())
	animation_player.stop()
	animation_player.play("HeartAnimations/hurt")
	animation_player.animation_set_next("HeartAnimations/hurt", "HeartAnimations/heartbeat")

func _on_heart_revealed_changed(val: bool):
	if val == true:
		sprite.modulate = revealed_color
		collision_layer = CollisionLayer.ENEMY_HITBOX
		collision_mask = CollisionLayer.ENEMY_HITBOX
		animation_player.play("HeartAnimations/heartbeat")
