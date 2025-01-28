extends Node

var arena: Arena
var boss: BossMonster
var overlay: BattleOverlay

signal boss_spawned
signal battle_begun

func spawn_boss_to_arena(_b, to_arena: Arena):
	boss = preload("res://Boss/SpiderBot.tscn").instantiate()
	var spawn_loc = Vector2(300, 500)
	boss.position = spawn_loc
	boss.arena = to_arena
	to_arena.add_child(boss)
	boss.controller.connect("boss_phase_changed", _on_boss_phase_changed)
	boss_spawned.emit(boss)
	boss.controller.boss_defeated.connect(overlay._on_boss_defeated)
	battle_begun.connect(boss.controller._on_battle_begun)
	#monsters.append(boss)

func _ready() -> void:
	var root = get_tree().root
	overlay = root.find_child("BattleOverlay", true, false)
	pass
	#if overlay == null:
		#overlay = preload("res://UI/BattleOverlay.tscn").instantiate()
		#root.add_child(overlay)
func begin_battle():
	battle_begun.emit()
	pass
	
func end_battle():
	if boss != null:
		boss.queue_free()
	overlay.boss_health_bar.visible = false

func spawn_player_to_arena(to_arena: Arena):
	arena = to_arena
	Player.spawn_to_arena(arena)
	#Player.player_health_changed.connect(overlay._on_player_health_changed)

func _on_boss_phase_changed(_phase):
	boss.controller.process_mode = Node.PROCESS_MODE_DISABLED
	Player.entity.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	overlay.connect("transition_finished", _on_transition_finished)
	#overlay._on_boss_phase_changed()
	
func _on_transition_finished():
	boss.controller.process_mode = Node.PROCESS_MODE_INHERIT
	Player.entity.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	#boss.heart.revealed = true
	overlay.disconnect("transition_finished", _on_transition_finished)
