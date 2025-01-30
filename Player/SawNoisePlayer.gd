extends Node

var idle: AudioStreamRandomizer = load("res://Audio/saw_idle.tres")
var rev_up: AudioStreamRandomizer = load("res://Audio/saw_rev_up.tres")
var run: AudioStreamRandomizer = load("res://Audio/saw_run.tres")
var rev_down: AudioStreamRandomizer = load("res://Audio/saw_rev_down.tres")

@onready var run_player: AudioStreamPlayer = $RunSound
@onready var rev_player: AudioStreamPlayer = $RevSound

var cut_timer: Timer = Timer.new()
var min_cut_time: float = .3
var cut_interval: Timer = Timer.new()
var min_cut_interval: float = .1
var rev_down_cutoff: Timer = Timer.new()
var rev_down_time: float = .69

func _ready() -> void:
	cut_timer.one_shot = true
	add_child(cut_timer)
	cut_interval.one_shot = true
	add_child(cut_interval)
	rev_down_cutoff.one_shot = true
	add_child(rev_down_cutoff)

func _on_move_state_changed(prev: PlayerEntity.MoveState, curr: PlayerEntity.MoveState):
	if prev == PlayerEntity.MoveState.MOVING and curr == PlayerEntity.MoveState.DASH_CHARGING:
		rev_player.stream = rev_up
		rev_player.play()
		run_player.stream = run
		run_player.play()
	elif prev == PlayerEntity.MoveState.DASH_CHARGING and curr == PlayerEntity.MoveState.MOVING:
		rev_player.stream = rev_down
		rev_player.play()
		run_player.stream = idle
		run_player.play()
	elif prev == PlayerEntity.MoveState.DASH_CHARGING and curr == PlayerEntity.MoveState.DASHING:
		run_player.stream = run
		run_player.play()
	elif prev == PlayerEntity.MoveState.DASHING and curr == PlayerEntity.MoveState.MOVING:
		rev_player.stream = rev_down
		rev_player.play()
		run_player.stream = idle
		run_player.play()
		

func _on_cut_state_changed(prev: Destructor.CutState, curr: Destructor.CutState):
	#if curr == Destructor.CutState.READY and prev == Destructor.CutState.END_CUT:
		#stream = idle
		#play()
	if curr == Destructor.CutState.BEGIN_CUT:
		#if rev_player.playing == true and rev_player.stream == rev_down:
			#await rev_player.finished
			#if Player.entity.destructor.cut_state != Destructor.CutState.CUTTING and Player.entity.destructor.cut_state != Destructor.CutState.BEGIN_CUT:
				#return
		if rev_player.stream != rev_up:
			rev_player.stream = rev_up
			rev_player.play()
	elif curr == Destructor.CutState.CUTTING:
		if rev_player.stream == rev_up and rev_player.playing == true:
			await rev_player.finished
			if Player.entity.destructor.cut_state != Destructor.CutState.CUTTING and Player.entity.destructor.cut_state != Destructor.CutState.BEGIN_CUT:
				return
		run_player.stream = run
		run_player.play()
	elif curr == Destructor.CutState.END_CUT:
		if rev_player.playing == true and rev_player.stream == rev_up:
			await rev_player.finished
			if Player.entity.destructor.cut_state != Destructor.CutState.READY and Player.entity.destructor.cut_state != Destructor.CutState.END_CUT:
				return
		rev_player.stream = rev_down
		rev_player.play()
		#rev_down_cutoff.start(rev_down_time)
		#await rev_down_cutoff.timeout
	elif curr == Destructor.CutState.READY:
		#if prev == Destructor.CutState.END_CUT:
			
		if rev_player.playing == true and rev_player.stream == rev_down:
			await rev_player.finished
			if Player.entity.destructor.cut_state != Destructor.CutState.READY and Player.entity.destructor.cut_state != Destructor.CutState.END_CUT:
				return
		run_player.stream = idle
		run_player.play()
