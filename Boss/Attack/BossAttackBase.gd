extends Node
class_name BossAttackBase

var boss: BossMonster
var arena: Node2D

func _move_to_position(pos: Vector2):
	for hitbox in boss.destructibles.get_children():
		for coll in hitbox.get_children():
			if coll is CollisionPolygon2D:
				coll.position = pos
