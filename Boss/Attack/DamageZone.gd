extends Area2D

var repeating: bool = false
var interval: float = 0
var duration: float = 0

func _damage_entities():
	for child in get_children():
		if child is CollisionPolygon2D:
			var entities = get_overlapping_bodies()
			if entities.contains(Player.entity.hitbox):
				pass

func _physics_process(delta: float) -> void:

	pass
