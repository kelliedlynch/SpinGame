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

var _max_health: int = 100
var max_health: int:
	get:
		return _max_health
	set(value):
		_max_health = value
		emit_signal("boss_health_changed", _current_health, value)
		
var _current_health: int = _max_health
var current_health: int:
	get:
		return _current_health
	set(value):
		_current_health = value
		emit_signal("boss_health_changed", value, _max_health)
		
signal boss_health_changed

var _boss_phase: BossPhase = BossPhase.NORMAL
var boss_phase: BossPhase:
	get: return _boss_phase
	set(value):
		emit_signal("boss_phase_changed", _boss_phase, value)
		_boss_phase = value

signal boss_phase_changed

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED

func _ready() -> void:
	attacks.append(JumpAndSmash.new(boss, self))
	attacks.append(LaserBeam.new(boss, self))
	boss.heart_revealed.connect(set.bind("boss_phase", BossPhase.HEART_EXPOSED))
	#boss_phase_changed.connect(_on_boss_phase_changed)
	for atk in attacks:
		#atk.boss = boss
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

#func _on_boss_phase_changed(_old_val, _new_val):
	#animation_player.get_animation("default/heartbeat").loop_mode = Animation.LOOP_LINEAR
	#animation_player.play("default/heartbeat")
	

func deal_damage(dmg: int):
	current_health -= dmg
	if current_health <= 0:
		boss.queue_free()

enum BossState {
	IDLE,
	ATTACKING
}

enum BossPhase {
	NORMAL,
	HEART_EXPOSED
}
