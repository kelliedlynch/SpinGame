@tool
extends Control
class_name BattleOverlay

@onready var player_health_bar: TextureProgressBar = $VBoxContainer/footer/HBoxContainer/health_bar
@onready var boss_name: Label = $VBoxContainer/header/HBoxContainer/MarginContainer2/boss_name
@onready var boss_health_bar: TextureProgressBar = $VBoxContainer/header/HBoxContainer/MarginContainer/boss_health_bar
@onready var ani_health: AnimationPlayer = $HealthBarAnimationPlayer
@onready var ani_text: AnimationPlayer = $TextAnimationPlayer
@onready var transition_text: Label = $VBoxContainer/main/animated_text/transition_text
@onready var boss_intro_name: Label = $VBoxContainer/main/animated_text/boss_name
@onready var boss_intro_round: Label = $VBoxContainer/main/animated_text/round_number
@onready var retry_button: Button = $VBoxContainer/main/MarginContainer/retry_button
var dash_charge_bar: TextureProgressBar

signal transition_finished

func _init() -> void:
	name = "BattleOverlay"
	z_index = RenderLayer.BATTLE_OVERLAY

func _ready() -> void:
	retry_button.pressed.connect(BattleManager.begin_battle)
	retry_button.pressed.connect(retry_button.set.bind("visible", false))
	BattleManager.player_spawned.connect(_on_player_spawned)
	BattleManager.boss_spawned.connect(_on_boss_spawned)
	Player.player_health_changed.connect(_on_player_health_changed)
	
#func _process(delta: float) -> void:
	#if Player.entity != null and Player.entity.destructor != null:
		#$VBoxContainer/footer/HBoxContainer/cut_power.text = str(Player.entity.destructor.get_power())

func _on_boss_spawned(boss: BossMonster):
	boss.controller.boss_health_changed.connect(_on_boss_health_changed)
	boss.controller.connect("boss_phase_changed", _on_boss_phase_changed)
	boss_name.text = boss.boss_name
	boss_intro_round.text = "Round " + str(BattleManager.current_boss + 1)
	boss_intro_name.text = boss.boss_name
	ani_text.play("boss_intro")
	ani_text.animation_finished.connect(transition_finished.emit, ConnectFlags.CONNECT_ONE_SHOT)
	
func _on_player_spawned():
	dash_charge_bar = load("res://UI/DashChargeBar.tscn").instantiate()
	Player.entity.hitbox.add_child(dash_charge_bar)
	dash_charge_bar.position += Vector2(0, 80)
	Player.entity.dash_cooldown_changed.connect(_on_dash_cooldown_changed)
	Player.entity.dash_ready.connect(_on_dash_ready)
	
func _on_dash_ready():
	var ready_text = TransitionText.new()
	ready_text.text = "Dash Ready!"
	ready_text.font_size = 30
	ready_text.modulate = Color.LIME_GREEN
	ready_text.outline = 1
	Player.entity.hitbox.add_child(ready_text)
	ready_text.position += Vector2(0, 80)
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(ready_text, "scale", Vector2(2, 2), 1.3)
	tween.tween_property(ready_text, "modulate:a", .2, 1.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(ready_text, "position:y", ready_text.position.y - 100, 1.3)
	tween.finished.connect(ready_text.queue_free)
	
func _on_dash_cooldown_changed(val: float):
	dash_charge_bar.value = val

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
	tween.tween_interval(ani_text.get_animation("slam_transition_text").length + .4)
	tween.tween_callback(ani_health.play.bind("fill_boss_health_bar"))
	var fill_time = ani_text.get_animation("fill_boss_health_bar").length
	tween.tween_interval(fill_time * .5)
	tween.tween_callback(transition_text.set.bind("visible", false))
	tween.tween_interval(fill_time * .4)
	tween.tween_callback(transition_finished.emit)

func _on_boss_defeated():
	transition_text.text = "You Win"
	ani_text.play("slam_transition_text")
	boss_health_bar.visible = false
	var tween = create_tween()
	tween.tween_interval(ani_text.get_animation("slam_transition_text").length + 2)
	tween.tween_callback(transition_text.set.bind("visible", false))
	tween.tween_callback(transition_finished.emit.bind(ConnectFlags.CONNECT_ONE_SHOT))
	#ani_text.animation_finished.connect(transition_finished.emit, ConnectFlags.CONNECT_ONE_SHOT)

func _on_player_defeated():
	transition_text.text = "You Lose"
	ani_text.play("slam_transition_text")
	boss_health_bar.visible = false
	var tween = create_tween()
	tween.tween_interval(ani_text.get_animation("slam_transition_text").length + 2)
	#tween.tween_callback(transition_text.set.bind("visible", false))
	tween.tween_callback(transition_finished.emit.bind(ConnectFlags.CONNECT_ONE_SHOT))
	tween.tween_callback(retry_button.set.bind("visible", true))
	#retry_button.visible = true
	
