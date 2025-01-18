extends Node

var animation_player: AnimationPlayer
var atk_speed = 1
var boss_state = BossState.IDLE
@onready var atk_tween: Tween

func _process(delta: float) -> void:
	if boss_state == BossState.IDLE:
		if atk_tween == null:
			atk_tween = create_tween()
			atk_tween.tween_interval(atk_speed)
			atk_tween.tween_callback(attack)
	elif boss_state == BossState.ATTACKING:
		pass
			
func attack():
	
	pass
		

enum BossState {
	IDLE,
	ATTACKING
}
