extends Node2D
class_name SGBaseEntity
# Base class for all physics entities.

@onready var visible_node: Node2D = $VisibleObject
var physics_node: PhysicsBody2D
var hitbox: CollisionPolygon2D

func _ready() -> void:
	for n in get_children():
		if n is PhysicsBody2D:
			physics_node = n
			hitbox = n.get_node("Hitbox")
			if n is RigidBody2D:
				n.gravity_scale = 0
			break
	pass

func generate_circle_polygon(radius) -> Array[Vector2]:
	var min_pts = 18
	var vertices: Array[Vector2] = []
	var pts = max(min_pts, int(360 / radius))
	var interval = 2 * PI / pts
	for i in pts:
		var pt = Vector2(radius * sin(i * interval), radius * cos(i * interval))
		#pt += Vector2(radius, radius)
		vertices.append(pt)
	return vertices

func _process(delta: float) -> void:
	visible_node.global_position = physics_node.global_position
	visible_node.rotation = physics_node.rotation
