@tool
extends StaticBody2D

var size: Vector2

@onready var l_wall: CollisionShape2D = $LeftWall
@onready var r_wall: CollisionShape2D = $RightWall
@onready var t_wall: CollisionShape2D = $TopWall
@onready var b_wall: CollisionShape2D = $BottomWall

func _ready() -> void:
	size = get_viewport_rect().size
	var thickness = size.x / 50
	
	
	#var l = $LeftWall
	l_wall.shape.size = Vector2(thickness, size.y)
	l_wall.position = l_wall.shape.size / 2
	r_wall.shape.size = Vector2(thickness, size.y)
	r_wall.position = Vector2(size.x, 0) - Vector2(r_wall.shape.size.x / 2, -r_wall.shape.size.y / 2)
	t_wall.shape.size = Vector2(size.x, thickness)
	t_wall.position = t_wall.shape.size / 2
	b_wall.shape.size = Vector2(size.x, thickness)
	b_wall.position = Vector2(0, size.y) - Vector2(-b_wall.shape.size.x / 2, b_wall.shape.size.y / 2)
