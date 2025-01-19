extends Node
class_name BossController

var animation_player: AnimationPlayer
var atk_speed = 1
var boss_state = BossState.IDLE
var atk_timer: Tween
var atk_perform: Tween

func _process(_delta: float) -> void:
	if boss_state == BossState.IDLE:
		atk_perform = null
		if atk_timer == null:
			atk_timer = create_tween()
			atk_timer.tween_interval(atk_speed)
			atk_timer.tween_callback(attack)
	elif boss_state == BossState.ATTACKING:
		pass
			
func attack():
	boss_state = BossState.ATTACKING
	atk_timer = null
	JumpAndSmash.execute_attack(get_parent())
	
	#atk_perform.tween_property(self, "boss_state", BossState.IDLE, 0)
	


func _disable_collision(entity):
	for shape in entity.hitbox:
		shape.collision_layer = 5
	pass
		

enum BossState {
	IDLE,
	ATTACKING
}
