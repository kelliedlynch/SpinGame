extends Node
class_name BossController

@onready var boss: BossMonster = get_parent()
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
var atk_speed = 1
var atk_timer: Tween
#var atk_perform: Tween
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
		boss_health_changed.emit(_current_health, value)
		
var _current_health: int = _max_health
var current_health: int:
	get:
		return _current_health
	set(value):
		_current_health = value
		boss_health_changed.emit(value, _max_health)
signal boss_health_changed

var _boss_phase: int = 0
var boss_phase: int:
	get: return _boss_phase
	set(value):
		boss_phase_changed.emit(value)
		_boss_phase = value
signal boss_phase_changed

var _boss_state: BossState = BossState.IDLE
var boss_state: BossState:
	get: return _boss_state
	set(value):
		boss_state_changed.emit(_boss_state, value)
		_boss_state = value
signal boss_state_changed

signal boss_defeated

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED

func _ready() -> void:
	boss_state_changed.connect(_on_boss_state_changed)
	for atk in attacks:
		atk.attack_finished.connect(_on_attack_finished)
		add_child(atk)
	
	#boss_state = BossState.IDLE
	
func _on_battle_begun():
	process_mode = ProcessMode.PROCESS_MODE_INHERIT
	boss_state = BossState.IDLE
	
func _on_battle_ended():
	for child in get_children():
		if child is BossAttackBase:
			child.queue_free()
	BattleManager.overlay.transition_finished.disconnect(_post_transition_knockback)
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	boss_state = BossState.IDLE

func _on_boss_state_changed(prev: BossState, curr: BossState):
	if curr == BossState.IDLE:
		boss.animation_player.queue("idle")
	pass

func _process(_delta: float) -> void:
	if boss_state == BossState.IDLE:
		#if boss.animation_player.is_playing() == false:
			#boss.animation_player.play("idle")
		#atk_perform = null
		if atk_timer == null:
			atk_timer = create_tween()
			atk_timer.tween_interval(atk_speed)
			atk_timer.tween_callback(attack)

func attack():
	boss_state = BossState.ATTACKING
	atk_timer = null
	if attacks.is_empty(): return
	attacks[attack_index].execute_attack()
	if attack_index < attacks.size() - 1:
		attack_index += 1
	else:
		attack_index = 0

func _on_attack_finished():
	boss_state = BossState.IDLE

func take_damage(dmg: int):
	current_health -= dmg
	boss.heart._on_dealt_damage()
	boss.tangible = false
	if current_health <= 0:
		var splat = load("res://BloodSplatParticles.tscn").instantiate()
		splat.global_position = boss.heart.global_position
		arena.add_child(splat)
		splat.emitting = true
		boss_defeated.emit()
		boss.queue_free()
		return
	_post_transition_knockback()
		
func _on_heart_revealed_changed(val: bool) -> void:
	if val == true:
		boss.tangible = false
		BattleManager.overlay.transition_finished.connect(_post_transition_knockback)
		boss_phase += 1
	
#func _on_battle_transition_finished(_foo = null):
	#call_deferred("_post_transition_knockback")
	#boss.heart.tangible = true

func _post_transition_knockback(_foo = null):
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
