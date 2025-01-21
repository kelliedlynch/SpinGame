@tool
extends StaticBody2D
class_name ArenaBorder

var size: Vector2

@onready var l_wall: CollisionShape2D = $LeftWall
@onready var r_wall: CollisionShape2D = $RightWall
@onready var t_wall: CollisionShape2D = $TopWall
@onready var b_wall: CollisionShape2D = $BottomWall

# depth needs to be fairly high to prevent player being knocked out of arena
var depth: float = 300
# wall_thickness is how much of the wall is actually on screen
var wall_thickness: float = 10

func make_walls() -> void:
	l_wall.shape.size = Vector2(depth, size.y + depth * 2)
	l_wall.position = Vector2(wall_thickness - depth / 2, size.y / 2)
	r_wall.shape.size = l_wall.shape.size
	r_wall.position = Vector2(size.x - wall_thickness + depth / 2, size.y / 2)
	t_wall.shape.size = Vector2(size.x + depth * 2, depth)
	t_wall.position = Vector2(size.x / 2, wall_thickness - depth / 2)
	b_wall.shape.size = t_wall.shape.size
	b_wall.position = Vector2(size.x / 2, size.y - wall_thickness + depth / 2)
