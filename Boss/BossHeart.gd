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

var tangible: bool:
	set(value):
		change_tangible_state.emit(value)
		tangible = value
signal change_tangible_state

var hidden_color: Color = Color.DIM_GRAY
var revealed_color: Color = Color.INDIAN_RED

func _ready() -> void:
	sprite.modulate = hidden_color
	change_tangible_state.connect(_on_tangible_changed)

func _on_dealt_damage():
	#if node is PlayerHitbox:
		#get_parent().controller.deal_damage(node.destructor.get_power())
	tangible = false
	animation_player.stop()
	animation_player.play("HeartAnimations/hurt")
	var tween = create_tween()
	tween.tween_interval(animation_player.get_animation("HeartAnimations/hurt").length)
	tween.tween_callback(animation_player.play.bind("HeartAnimations/flash"))
	tween.tween_interval(1)
	tween.tween_callback(animation_player.play.bind("HeartAnimations/heartbeat"))
	tween.tween_callback(set.bind("tangible", true))

func _on_heart_revealed_changed(val: bool):
	if val == true:
		sprite.modulate = revealed_color
		animation_player.play("HeartAnimations/heartbeat")
		tangible = false
		#await get_tree().create_timer(5).timeout


func _on_tangible_changed(val: bool):
	if val == true:
		collision_layer = CollisionLayer.ENEMY_HITBOX
		collision_mask = CollisionLayer.ENEMY_HITBOX
	else:
		collision_layer = CollisionLayer.INTANGIBLE_ENEMY
		collision_mask = CollisionLayer.INTANGIBLE_ENEMY
		
