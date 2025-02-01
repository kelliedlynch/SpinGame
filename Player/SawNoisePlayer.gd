extends Node

var idle: AudioStreamRandomizer = load("res://Audio/saw_idle.tres")
var rev_up: AudioStreamRandomizer = load("res://Audio/saw_rev_up.tres")
var run: AudioStreamRandomizer = load("res://Audio/saw_run.tres")
var rev_down: AudioStreamRandomizer = load("res://Audio/saw_rev_down.tres")
var dash_up: AudioStreamRandomizer = load("res://Audio/dash_spin_up.tres")
var dashing: AudioStreamRandomizer = load("res://Audio/dash_run.tres")
var dash_down: AudioStreamRandomizer = load("res://Audio/dash_spin_down.tres")

@onready var run_player: AudioStreamPlayer = $RunSound
@onready var rev_player: AudioStreamPlayer = $RevSound
@onready var dash_player: AudioStreamPlayer = $DashSound

var cut_timer: Timer = Timer.new()
var min_cut_time: float = .3
var cut_interval: Timer = Timer.new()
var min_cut_interval: float = .1


func _ready() -> void:
	cut_timer.one_shot = true
	add_child(cut_timer)
	cut_interval.one_shot = true
	add_child(cut_interval)


func _on_move_state_changed(prev: PlayerEntity.MoveState, curr: PlayerEntity.MoveState):
	if prev == PlayerEntity.MoveState.MOVING and curr == PlayerEntity.MoveState.DASH_CHARGING:
		dash_player.stream = dash_up
		dash_player.play()
		#await dash_player.finished
		dash_player.finished.connect(_dash_run_if_dashing, ConnectFlags.CONNECT_ONE_SHOT)
	elif prev == PlayerEntity.MoveState.DASH_CHARGING and curr == PlayerEntity.MoveState.MOVING:
		if dash_player.finished.is_connected(_dash_run_if_dashing):
			dash_player.finished.disconnect(_dash_run_if_dashing)
		dash_player.stream = dash_down
		dash_player.play()
	elif prev == PlayerEntity.MoveState.DASH_CHARGING and curr == PlayerEntity.MoveState.DASHING:
		#if dash_player.playing == true and dash_player.stream == dash_up:
			#dash_player.stream = dashing
			#dash_player.play()
		pass
	elif prev == PlayerEntity.MoveState.DASHING and curr == PlayerEntity.MoveState.MOVING:
		if dash_player.finished.is_connected(_dash_run_if_dashing):
			dash_player.finished.disconnect(_dash_run_if_dashing)
		dash_player.stream = dash_down
		dash_player.play()
		
func _dash_run_if_dashing():
	var state = Player.entity.move_state
	if state == PlayerEntity.MoveState.DASHING or state == PlayerEntity.MoveState.DASH_CHARGING:
		dash_player.stream = dashing
		dash_player.play()
		
func _rev_up_if_cutting():
	pass
	
func _rev_down_if_done():
	var state = Player.entity.destructor.cut_state
	if state == Destructor.CutState.READY:
		rev_player.stream = rev_down
		rev_player.play()

func _run_if_cutting():
	var state = Player.entity.destructor.cut_state
	if state == Destructor.CutState.CUTTING:
		run_player.stream = run	
		run_player.play()

func _idle_if_done():
	run_player.stream = idle
	run_player.play()

func _on_cut_state_changed(prev: Destructor.CutState, curr: Destructor.CutState):
	#if curr == Destructor.CutState.READY and prev == Destructor.CutState.END_CUT:
		#stream = idle
		#play()
	if curr == Destructor.CutState.BEGIN_CUT:
		#if (rev_player.playing == true and rev_player.stream == rev_down) \
				#or (rev_player.playing == false and run_player.stream == idle):
		#if rev_player.finished.is_connected(_rev_down_if_done):
			#rev_player.finished.disconnect(_rev_down_if_done)
		if (run_player.stream == run and run_player.playing == true) \
				or (rev_player.stream == rev_up and rev_player.playing == true):
			if rev_player.finished.is_connected(_rev_down_if_done):
				rev_player.finished.disconnect(_rev_down_if_done)
			pass
		else:
			if rev_player.finished.is_connected(_rev_down_if_done):
				rev_player.finished.disconnect(_rev_down_if_done)
			rev_player.stream = rev_up
			rev_player.play()
		#if run_player.stream != run:
			#run_player.stream = run
	elif curr == Destructor.CutState.CUTTING:
		#if prev == Destructor.CutState.END_CUT:
			#if run_player.stream != run:
				#run_player.stream = run
		if rev_player.finished.is_connected(_rev_down_if_done):
			rev_player.finished.disconnect(_rev_down_if_done)
		#if rev_player.finished.get_connections().has(_run_if_cutting):
			#rev_player.finished.disconnect(_run_if_cutting)
		if rev_player.playing == true:
			#if rev_player.stream == rev_up:
				##rev_player.finished.connect(_run_if_cutting, ConnectFlags.CONNECT_ONE_SHOT)
				#pass
			if rev_player.stream == rev_down:
				rev_player.stop()
				if rev_player.finished.is_connected(_rev_down_if_done):
					rev_player.finished.disconnect(_rev_down_if_done)
			if run_player.stream != run:
				run_player.stream = run
				run_player.volume_db = -14
			run_player.play()
		else:
			#run_player.stream = run
			if run_player.playing == false:
				run_player.play()
		pass
	elif curr == Destructor.CutState.END_CUT:
		#if rev_player.finished.is_connected(run_player.play):
			#rev_player.finished.disconnect(run_player.play)
		#run_player.stop()
		if rev_player.playing and rev_player.stream == rev_up:
			rev_player.finished.connect(_rev_down_if_done, ConnectFlags.CONNECT_ONE_SHOT)
		else:
			rev_player.stream = rev_down
			if rev_player.finished.is_connected(_rev_down_if_done):
				rev_player.finished.disconnect(_rev_down_if_done)
			rev_player.play()
	elif curr == Destructor.CutState.READY:
		#if rev_player.finished.is_connected(run_player.play):
			#rev_player.finished.disconnect(run_player.play)
		#run_player.call_deferred("stop")
		run_player.stream = idle
		run_player.volume_db = -24
		run_player.play()
		#if (rev_player.playing == true and rev_player.stream == rev_down):
			#rev_player.finished.connect(_idle_if_done, ConnectFlags.CONNECT_ONE_SHOT)
		#run_player.stream = idle
		#run_player.play()
		pass
