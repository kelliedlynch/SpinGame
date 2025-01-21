extends Node2D
class_name BossMonster

@onready var controller: BossController = $BossController
@onready var destructibles: Node2D = $Destructibles
var arena: Arena

#func _init() -> void:
	#tree_entered.connect(_add_to_arena)

func _ready() -> void:
	z_index = RenderLayer.ARENA_ENTITIES
	$shadow.z_index = RenderLayer.ENTITY_SHADOWS
	$shadow.z_as_relative = false
	controller.animation_player = $AnimationPlayer
	#item_rect_changed.connect(_on_item_rect_changed)
	for child in destructibles.get_children():
		child.boss = self
		child.tree_exited.connect(_on_shape_destroyed)

	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2

func _on_shape_destroyed():
	if destructibles.get_child_count() == 0:
		queue_free()

func calculate_size() -> Vector2:
	var min_x = 1000000
	var max_x = 0
	var min_y = 1000000
	var max_y = 0
	for child in destructibles.get_children():
		for poly in child.get_children():
			if poly is CollisionPolygon2D:
				for vertex in poly.polygon:
					var v = poly.to_global(vertex)
					if v.x < min_x: min_x = v.x
					if v.y < min_y: min_y = v.y
					if v.x > min_x: max_x = v.x
					if v.y > min_y: max_y = v.y
	return Vector2(max_x - min_x, max_y - min_y)

func move_to_position(pos: Vector2):
	for hitbox in destructibles.get_children():
		for coll in hitbox.get_children():
			if coll is CollisionPolygon2D:
				coll.position = pos
