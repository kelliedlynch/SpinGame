extends Node

var max_move_speed: int = 2000
var move_power = 1000

var _max_health: int = 100
var max_health: int:
	get:
		return _max_health
	set(value):
		_max_health = value
		player_health_changed.emit(_current_health, value)
		
var _current_health: int = _max_health
var current_health: int:
	get:
		return _current_health
	set(value):
		_current_health = value
		player_health_changed.emit(value, _max_health)
		
var _invincible: bool = false
var invincible: bool:
	get: return _invincible
	set(value):
		change_invincible_state.emit(value)
		_invincible = value
signal change_invincible_state

var entity: PlayerEntity
var arena: Arena
var hitbox: PlayerHitbox:
	get:
		return entity.hitbox if entity else null

signal took_damage
signal player_health_changed
signal player_defeated

func take_damage(dmg: int) -> void:
	if invincible == true: return
	current_health -= dmg
	if current_health <= 0:
		player_defeated.emit()
		entity.queue_free()
	else:
		invincible = true
		emit_signal("took_damage", dmg)
		await get_tree().create_timer(1).timeout
		invincible = false
		
func spawn_to_arena(a: Arena):
	if entity != null:
		entity.queue_free()
	arena = a
	entity = preload("res://Player/PlayerEntity.tscn").instantiate()
	entity.position = arena.spawn_point
	arena.add_child(entity)
	change_invincible_state.connect(entity._on_invincible_state_changed)
	#emit_signal("player_health_changed", current_health, max_health)
	took_damage.connect(entity._on_take_damage)
	current_health = max_health
