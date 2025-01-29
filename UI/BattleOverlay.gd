@tool
extends Control
class_name BattleOverlay

@onready var player_health_bar: TextureProgressBar = $VBoxContainer/footer/HBoxContainer/health_bar
@onready var boss_name: Label = $VBoxContainer/header/HBoxContainer/MarginContainer2/boss_name
@onready var boss_health_bar: TextureProgressBar = $VBoxContainer/header/HBoxContainer/MarginContainer/boss_health_bar
@onready var ani_health: AnimationPlayer = $HealthBarAnimationPlayer
@onready var ani_text: AnimationPlayer = $TextAnimationPlayer
@onready var transition_text: Node2D = $VBoxContainer/main/transition_text
@onready var boss_intro_name: Node2D = $VBoxContainer/main/boss_name
@onready var boss_intro_round: Node2D = $VBoxContainer/main/round_number

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
	boss_name.text = boss.boss_name
	boss_intro_round.text = "Round " + str(BattleManager.current_boss + 1)
	boss_intro_name.text = boss.boss_name
	ani_text.play("boss_intro")
	ani_text.animation_finished.connect(transition_finished.emit)

func _on_player_health_changed(current: int, max_val: int):
	player_health_bar.max_value = max_val
	player_health_bar.value = current

func _on_boss_health_changed(current: int, max_val: int):
	boss_health_bar.max_value = max_val
	boss_health_bar.value = current
	
func _on_boss_phase_changed(_phase):
	transition_text.text = "Heart Exposed"
	ani_text.play("slam_transition_text")
	var tween = create_tween()
	tween.tween_interval(.5)
	tween.tween_callback(ani_health.play.bind("fill_boss_health_bar"))
	tween.tween_interval(ani_text.current_animation_length * .9)
	tween.tween_callback(transition_finished.emit)

func _on_boss_defeated():
	transition_text.text = "You Win"
	ani_text.play("slam_transition_text")
	boss_health_bar.visible = false
	ani_text.animation_finished.connect(transition_finished.emit)

func _on_player_defeated():
	transition_text.text = "You Lose"
	ani_text.play("slam_transition_text")
	boss_health_bar.visible = false
	ani_text.animation_finished.connect(transition_finished.emit)
