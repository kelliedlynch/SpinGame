extends Control

@onready var arena: Arena = $Arena
@onready var ani: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

var success: AudioStreamOggVorbis = load("res://Audio/bling_1.ogg")

var total_input_vector_needed: float = 3000
var dash_input_events
var phase: Phase = Phase.BEGIN
var accum_aim: float = .1

func _ready() -> void:
	BattleManager.bosses = ["TutorialTarget", "TutorialTarget"]
	BattleManager.battle_beginning.disconnect(arena.audio._on_battle_beginning)
	BattleManager.battle_ended.disconnect(arena.audio._on_battle_ended)
	BattleManager.phase_changed.disconnect(arena.audio._on_phase_change)
	arena.audio.music.stream = load("res://Audio/Buzzsaws Loop.ogg")
	arena.audio.music.play()
	BattleManager.spawn_player_to_arena(arena)
	$movement_keys.visible = true
	ani.play("show_movement_keys")
	Player.entity.input_vector_changed.connect(_on_input_vector_changed)
	dash_input_events = InputMap.action_get_events("gameplay_begin_dash")
	InputMap.action_erase_events("gameplay_begin_dash")
	
func _on_input_vector_changed(oldval: Vector2, newval: Vector2):
	if newval == Vector2.ZERO:
		var a = oldval.length_squared()
		total_input_vector_needed -= oldval.length()
	if total_input_vector_needed <= 0:
		ani.stop()
		audio.stream = success
		audio.play()
		Player.entity.input_vector_changed.disconnect(_on_input_vector_changed)
		_begin_dash_tutorial()
		
func _begin_dash_tutorial():
	phase = Phase.WAIT_DASH_START
	$movement_keys.visible = false
	$dash_keys.visible = true
	ani.play("show_dash_button")
	for event in dash_input_events:
		#if event.pressed == true:
		InputMap.action_add_event("gameplay_begin_dash", event)
	#dash_input_events = InputMap.action_get_events("gameplay_begin_dash")
	#InputMap.action_erase_events("gameplay_release_dash")
	pass

func _release_dash_tutorial():
	ani.play("dash_release_transition")
	for event in dash_input_events:
		InputMap.action_add_event("gameplay_begin_dash", event)
		
func _begin_cut_tutorial():
	
	#BattleManager.spawn_boss_to_arena("TutorialTarget", arena)
#
	#BattleManager.spawn_player_to_arena(arena)
	
	BattleManager.begin_battle()
	await BattleManager.battle_begun
	BattleManager.powerup_spawn.stop()
	
func _input(event: InputEvent) -> void:
	if phase == Phase.WAIT_DASH_START:
		if event.is_action_pressed("gameplay_begin_dash") == true:
			InputMap.action_erase_events("gameplay_begin_dash")
			ani.stop()
			$dash_keys.visible = true
			#$dash_keys/LKeyboardSpace.visible = true
			#$dash_keys/LKeyboardSpaceOutline.visible = false
			ani.play("dash_aim_transition")
			ani.queue("show_dash_aim")
			phase = Phase.WAIT_DASH_AIM
	if phase == Phase.WAIT_DASH_RELEASE:
		if event.is_action_released("gameplay_begin_dash"):
			ani.stop()
			audio.stream = success
			audio.play()
			phase = Phase.CUT
			$dash_keys.visible = false
			var timer = get_tree().create_timer(1.5)
			timer.timeout.connect(_begin_cut_tutorial)

func _process(delta: float) -> void:
	if phase == Phase.WAIT_DASH_AIM:
		if Input.is_action_pressed("gameplay_move_up") or Input.is_action_pressed("gameplay_move_down") or Input.is_action_pressed("gameplay_move_left") or Input.is_action_pressed("gameplay_move_right"):
			accum_aim -= delta
		if accum_aim < 0:
			phase = Phase.WAIT_DASH_RELEASE
			_release_dash_tutorial()

enum Phase {
	BEGIN,
	WAIT_MOVE,
	WAIT_DASH_START,
	WAIT_DASH_AIM,
	WAIT_DASH_RELEASE,
	CUT,
	POWERUP
}
