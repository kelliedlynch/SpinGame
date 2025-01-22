extends Node
class_name BossController

@onready var boss: BossMonster = get_parent()
var animation_player: AnimationPlayer
var atk_speed = 1
var boss_state = BossState.IDLE
var atk_timer: Tween
var atk_perform: Tween
@onready var arena: Arena = boss.arena

var attacks: Array[Node] = []
var attack_index = 0

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED

func _ready() -> void:
	attacks.append(JumpAndSmash.new(boss, self))
	attacks.append(LaserBeam.new(boss, self))
	for atk in attacks:
		#atk.boss = boss
		atk.arena = arena
		add_child(atk)
		process_mode = ProcessMode.PROCESS_MODE_INHERIT

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
		
#func _on_exiting_tree():
	#if atk_timer != null:
		#atk_timer.kill()
		#animation_player.stop()

enum BossState {
	IDLE,
	ATTACKING
}
