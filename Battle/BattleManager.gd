extends Node

var arena: Arena
var boss: BossMonster
#var boss_controller: BossController
#var monsters: Array[BossMonster]
var overlay: BattleOverlay

#signal transition_finished

func spawn_boss_to_arena(_b, to_arena: Arena):
	boss = preload("res://Boss/BossMonster.tscn").instantiate()
	var spawn_loc = Vector2(800, 400)
	boss.position = spawn_loc
	boss.arena = to_arena
	to_arena.add_child(boss)
	
	#monsters.append(boss)

func begin_battle():
	var root = get_tree().root
	overlay = root.find_child("BattleOverlay", true, false)
	if overlay == null:
		overlay = preload("res://UI/BattleOverlay.tscn").instantiate()
		root.add_child(overlay)
	Player.player_health_changed.connect(overlay._on_player_health_changed)
	boss.controller.boss_health_changed.connect(overlay._on_boss_health_changed)
	#boss.controller.boss_phase_changed.connect(overlay._on_boss_phase_changed)
	boss.controller.connect("boss_phase_changed", _on_boss_phase_changed)

func spawn_player_to_arena(to_arena: Arena):
	arena = to_arena
	Player.spawn_to_arena(arena)

func _on_boss_phase_changed(old_phase: BossController.BossPhase, new_phase: BossController.BossPhase):
	boss.controller.process_mode = Node.PROCESS_MODE_DISABLED
	Player.entity.process_mode = Node.PROCESS_MODE_DISABLED
	overlay.connect("transition_finished", _on_transition_finished)
	overlay._on_boss_phase_changed()
	
func _on_transition_finished():
	boss.controller.process_mode = Node.PROCESS_MODE_INHERIT
	Player.entity.process_mode = Node.PROCESS_MODE_INHERIT
	boss.heart.revealed = true
	overlay.disconnect("transition_finished", _on_transition_finished)
