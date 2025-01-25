extends Node
class_name BossController

@onready var boss: BossMonster = get_parent()
var animation_player: AnimationPlayer
var atk_speed = 1
var atk_timer: Tween
var atk_perform: Tween
@onready var arena: Arena = boss.arena

var attacks: Array[Node] = []
var attack_index = 0

var transition_knockback_force: int = 6000

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

var _boss_phase: int = 0
var boss_phase: int:
	get: return _boss_phase
	set(value):
		emit_signal("boss_phase_changed", value)
		_boss_phase = value

signal boss_phase_changed

var _boss_state: BossState = BossState.IDLE
var boss_state: BossState:
	get: return _boss_state
	set(value):
		emit_signal("boss_state_changed", _boss_state, value)
		_boss_state = value
signal boss_state_changed

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED

func _ready() -> void:
	attacks.append(JumpAndSmash.new(boss, self))
	attacks.append(LaserBeam.new(boss, self))
	for atk in attacks:
		add_child(atk)
		process_mode = ProcessMode.PROCESS_MODE_INHERIT

func _process(_delta: float) -> void:
	if boss_state == BossState.IDLE: 
		atk_perform = null
		if atk_timer == null:
			atk_timer = create_tween()
			atk_timer.tween_interval(atk_speed)
			atk_timer.tween_callback(attack)

			
func attack():
	boss_state = BossState.ATTACKING
	atk_timer = null
	attacks[attack_index].execute_attack()
	if attack_index < attacks.size() - 1:
		attack_index += 1
	else:
		attack_index = 0
	

func take_damage(dmg: int):
	current_health -= dmg
	boss.heart._on_dealt_damage()
	if current_health <= 0:
		boss.queue_free()
		
func _on_heart_revealed_changed(val: bool) -> void:
	if val == true:
		boss.tangible = false
		BattleManager.overlay.transition_finished.connect(_on_battle_transition_finished)
		boss_phase += 1
	
func _on_battle_transition_finished():
	
	#await boss.heart.heart_revealed_changed
	call_deferred("_post_transition_knockback")

func _post_transition_knockback():
	var angle = boss.heart.global_position.angle_to_point(Player.entity.hitbox.global_position)
	var vec = Vector2.from_angle(angle) * transition_knockback_force
	Player.entity.move_state = PlayerEntity.MoveState.MOVING
	Player.entity.hitbox.queued_force = vec
	await get_tree().create_timer(.8).timeout
	boss.tangible = true

enum BossState {
	IDLE,
	ATTACKING,
	MOVING
}
