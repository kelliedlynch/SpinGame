#@tool
extends AspectRatioContainer
class_name BattleOverlay

@onready var player_health_bar: TextureProgressBar = $VBoxContainer/footer/HBoxContainer/health_bar
@onready var boss_health_bar: TextureProgressBar = $VBoxContainer/header/HBoxContainer/MarginContainer/boss_health_bar
@onready var ani: AnimationPlayer = $AnimationPlayer

signal transition_finished

func _init() -> void:
	name = "BattleOverlay"
	z_index = RenderLayer.BATTLE_OVERLAY

func _ready() -> void:
	BattleManager.boss_spawned.connect(_on_boss_spawned)
	Player.player_health_changed.connect(_on_player_health_changed)
	
func _on_boss_spawned(boss: BossMonster):
	boss.controller.boss_health_changed.connect(_on_boss_health_changed)
	boss.controller.connect("boss_phase_changed", _on_boss_phase_changed)

func _on_player_health_changed(current: int, max_val: int):
	player_health_bar.max_value = max_val
	player_health_bar.value = current

func _on_boss_health_changed(current: int, max_val: int):
	boss_health_bar.max_value = max_val
	boss_health_bar.value = current
	
func _on_boss_phase_changed(_phase):
	ani.play("heart_phase_transition")
	var tween = create_tween()
	tween.tween_interval(ani.current_animation_length * .9)
	tween.tween_callback(transition_finished.emit)
