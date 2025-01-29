extends Node

var arena: Arena
var boss: BossMonster
var overlay: BattleOverlay

var bosses: PackedStringArray = ["OneArmedBandit", "SpiderBot", "Robotato"]
var current_boss: int = 0

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
	spawn_boss_to_arena(bosses[current_boss], arena)
	await overlay.transition_finished
	spawn_player_to_arena(arena)
	battle_begun.emit()
	pass
	
func _on_boss_defeated():
	battle_ended.emit()
	current_boss += 1
	if current_boss > bosses.size() - 1:
		assert(false)
	overlay.transition_finished.connect(begin_battle, ConnectFlags.CONNECT_ONE_SHOT)
		
func _on_player_defeated():
	battle_ended.emit()
	assert(false)
	
func _on_battle_ended():
	if Player.entity != null:
		Player.entity.queue_free()

func spawn_player_to_arena(to_arena: Arena):
	arena = to_arena
	Player.spawn_to_arena(arena)
	Player.player_defeated.connect(overlay._on_player_defeated)
	#Player.player_health_changed.connect(overlay._on_player_health_changed)

func _on_boss_phase_changed(_phase):
	boss.controller.process_mode = Node.PROCESS_MODE_DISABLED
	Player.entity.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	overlay.transition_finished.connect(_on_transition_finished, ConnectFlags.CONNECT_ONE_SHOT)
	#overlay._on_boss_phase_changed()
	
func _on_transition_finished(_foo = null):
	boss.controller.process_mode = Node.PROCESS_MODE_INHERIT
	Player.entity.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	#boss.heart.revealed = true
	#overlay.disconnect("transition_finished", _on_transition_finished)
