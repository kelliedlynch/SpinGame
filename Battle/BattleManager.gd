extends Node

var arena: Arena
var boss: BossMonster
var overlay: BattleOverlay

var bosses: PackedStringArray = ["OneArmedBandit", "SpiderBot", "Robotato"]
var current_boss: int = 0

var powerup: Powerup
var powerup_spawn: Tween
var powerup_spawn_time: float = 2

signal player_spawned
signal boss_spawned
signal battle_begun
signal battle_ended

func spawn_boss_to_arena(boss_name: String, to_arena: Arena):
	boss = load("res://Boss/" + boss_name + ".tscn").instantiate()
	var spawn_loc = Vector2(300, 500)
	boss.position = spawn_loc
	boss.arena = to_arena
	to_arena.add_child(boss)
	boss.controller.connect("boss_phase_changed", _on_boss_phase_changed)
	boss_spawned.emit(boss)
	boss.controller.boss_defeated.connect(overlay._on_boss_defeated)
	boss.controller.boss_defeated.connect(_on_boss_defeated)
	battle_ended.connect(boss.controller._on_battle_ended)
	battle_ended.connect(_on_battle_ended)
	battle_begun.connect(boss.controller._on_battle_begun)
	#monsters.append(boss)

func _ready() -> void:
	var root = get_tree().root
	overlay = root.find_child("BattleOverlay", true, false)

func begin_game():
	#arena = load("res://Arena/Arena.tscn").instantiate()
	get_tree().change_scene_to_file("res://Arena/Arena.tscn")
	await get_tree().tree_changed
	arena = get_tree().current_scene
	overlay = load("res://UI/BattleOverlay.tscn").instantiate()
	arena.add_child(overlay)
	begin_battle()

func begin_battle(_foo = null):
	if powerup_spawn != null:
		powerup_spawn.kill()
	if powerup != null:
		powerup.queue_free()
	if boss != null:
		boss.queue_free()
	spawn_boss_to_arena(bosses[current_boss], arena)
	if Player.entity != null:
		Player.entity.queue_free()
	await overlay.transition_finished
	spawn_player_to_arena(arena)
	_start_powerup_spawn_timer()
	battle_begun.emit()
	
func _start_powerup_spawn_timer():
	powerup_spawn = create_tween()
	powerup_spawn.tween_interval(powerup_spawn_time)
	powerup_spawn.tween_callback(spawn_powerup)

func _on_boss_defeated():
	battle_ended.emit()
	current_boss += 1
	if current_boss > bosses.size() - 1:
		get_tree().change_scene_to_file("res://UI/title_screen.tscn")
	overlay.transition_finished.connect(begin_battle, ConnectFlags.CONNECT_ONE_SHOT)
		
func _on_player_defeated():
	battle_ended.emit()
	await get_tree().create_timer(1).timeout
	Player.player_defeated.disconnect(overlay._on_player_defeated)
	Player.player_defeated.disconnect(_on_player_defeated)
	#get_tree().change_scene_to_file("res://UI/title_screen.tscn")
	
func _on_battle_ended():
	battle_ended.disconnect(boss.controller._on_battle_ended)
	battle_ended.disconnect(_on_battle_ended)
	battle_begun.disconnect(boss.controller._on_battle_begun)

func spawn_player_to_arena(to_arena: Arena):
	arena = to_arena
	Player.spawn_to_arena(arena)
	Player.player_defeated.connect(overlay._on_player_defeated)
	Player.player_defeated.connect(_on_player_defeated)
	player_spawned.emit()
	#Player.player_health_changed.connect(overlay._on_player_health_changed)

func _on_boss_phase_changed(_phase):
	boss.controller.process_mode = Node.PROCESS_MODE_DISABLED
	Player.entity.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	overlay.transition_finished.connect(_on_transition_finished, ConnectFlags.CONNECT_ONE_SHOT)
	#overlay._on_boss_phase_changed()
	
func _on_transition_finished(_foo = null):
	boss.controller.process_mode = Node.PROCESS_MODE_INHERIT
	Player.entity.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)

func spawn_powerup():
	powerup = preload("res://Entity/Powerup.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(600, 820), randi_range(100, 300))
	spawn_loc.y = spawn_loc.y if randi() % 2 == 0 else arena.get_viewport_rect().size.y - spawn_loc.y
	powerup.position = spawn_loc
	arena.add_child(powerup)
	powerup.tree_exited.connect(_start_powerup_spawn_timer)
