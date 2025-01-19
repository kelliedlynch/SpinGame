extends Node2D
class_name BossMonster

@onready var controller: BossController = $BossController
@onready var destructibles: Node2D = $Destructibles
var arena: Arena

#func _init() -> void:
	#tree_entered.connect(_add_to_arena)

func _ready() -> void:
	controller.animation_player = $AnimationPlayer
	#item_rect_changed.connect(_on_item_rect_changed)
	for child in destructibles.get_children():
		child.boss = self
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2

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


#func move_to_position(pos: Vector2):
	#position = pos
	#for hitbox in destructibles.get_children():
		#hitbox.position = pos
		#for coll in hitbox.get_children():
			#if coll is SGCollPoly:
				##var remote = coll.find_remote_transform()
				#coll.position = pos
