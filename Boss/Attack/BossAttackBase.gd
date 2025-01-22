extends Node
class_name BossAttackBase

var boss: BossMonster
var controller: BossController
var arena: Node2D
var min_damage: int = 10
var max_damage: int = 20

var atk_perform: Tween

func _init(boss_monster: BossMonster, boss_controller: BossController) -> void:
	boss = boss_monster
	controller = boss_controller
	pass

func get_damage():
	return randi_range(min_damage, max_damage)
