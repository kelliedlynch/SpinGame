extends Node


var _max_health: int = 100
var max_health: int:
	get:
		return _max_health
	set(value):
		_max_health = value
		emit_signal("player_health_changed", _current_health, value)
		
var _current_health: int = _max_health
var current_health: int:
	get:
		return _current_health
	set(value):
		_current_health = value
		emit_signal("player_health_changed", value, _max_health)

var entity: PlayerEntity

signal took_damage
signal player_health_changed

func deal_damage(dmg: int) -> void:
	current_health -= dmg
	if current_health <= 0:
		entity.queue_free()
	else:
		emit_signal("took_damage", dmg)
		
func spawn_to_arena(arena: Arena):
	entity = preload("res://Player/PlayerEntity.tscn").instantiate()
	entity.position = arena.spawn_point
	arena.add_child(entity)
	var root = arena.get_tree().root
	var gui = arena.get_tree().root.find_child("BattleOverlay", true, false)
	player_health_changed.connect(gui._on_player_health_changed)
	emit_signal("player_health_changed", current_health, max_health)
	took_damage.connect(entity._on_take_damage)
