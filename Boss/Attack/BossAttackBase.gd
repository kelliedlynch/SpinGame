extends Node
class_name BossAttackBase

var boss: BossMonster
var controller: BossController
#var arena: Node2D
var min_damage: int = 10
var max_damage: int = 20

var atk_perform: Tween

func _init(boss_monster: BossMonster, boss_controller: BossController) -> void:
	boss = boss_monster
	controller = boss_controller
	pass

func get_damage():
	return randi_range(min_damage, max_damage)

func _random_target_area(area_size: Vector2):
	var rect: Rect2 = BattleManager.arena.active_area
	var x = randi_range(rect.position.x + area_size.x / 2, rect.position.x + rect.size.x - area_size.x / 2)
	var y = randi_range(rect.position.y + area_size.y / 2, rect.position.y + rect.size.y - area_size.y / 2)
	return Vector2(x, y)
