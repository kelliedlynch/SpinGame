extends Node
class_name BossController

var animation_player: AnimationPlayer
var atk_speed = 1
var boss_state = BossState.IDLE
var atk_timer: Tween
var atk_perform: Tween

var attacks: Array[Node] = []
var attack_index = 0

func _ready() -> void:
	attacks.append(JumpAndSmash.new())
	var parent = get_parent()
	var arena = get_parent().get_parent().get_node("Arena")
	for atk in attacks:
		atk.boss = parent
		atk.arena = arena
		add_child(atk)

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
	attacks[attack_index].execute_attack()
	if attack_index < attacks.size() - 1:
		attack_index += 1
	else:
		attack_index = 0
		

enum BossState {
	IDLE,
	ATTACKING
}
