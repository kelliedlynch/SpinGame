@tool
extends StaticBody2D

var size: Vector2

@onready var l_wall: CollisionShape2D = $LeftWall
@onready var r_wall: CollisionShape2D = $RightWall
@onready var t_wall: CollisionShape2D = $TopWall
@onready var b_wall: CollisionShape2D = $BottomWall

# Called when the node enters the scene tree for the first time.
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
	
	
	#l.position = Vector2.ZERO
	
	#var lwcoll = CollisionShape2D.new()
	#var left_wall = RectangleShape2D.new()
	#left_wall.size = Vector2(thickness, size.y)
	#lwcoll.shape = left_wall
	#lwcoll.transform.origin = left_wall.size / 2
	#shape_owner_add_shape(0, left_wall)
	#add_child(lwcoll)
	#
	#var rwcoll = CollisionShape2D.new()
	#rwcoll.position = Vector2(size.x - thickness, 0)
	#var right_wall = RectangleShape2D.new()
	#right_wall.size = Vector2(thickness, size.y)
	#rwcoll.shape = right_wall
	#rwcoll.transform.origin = size - right_wall.size / 2
	#add_child(rwcoll)
	##
	#var twcoll = CollisionShape2D.new()
	#twcoll.position = Vector2.ZERO
	#var top_wall = RectangleShape2D.new()
	#top_wall.size = Vector2(size.x, thickness)
	#twcoll.shape = top_wall
	#twcoll.transform.origin = top_wall.size / 2
	#add_child(twcoll)
	##
	#var bwcoll = CollisionShape2D.new()
	#bwcoll.position = Vector2(0, size.y - thickness)
	#var bottom_wall = RectangleShape2D.new()
	#bottom_wall.size = Vector2(size.x, thickness)
	#bwcoll.shape = bottom_wall
	#bwcoll.transform.origin = size - bottom_wall.size / 2
	#add_child(bwcoll) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
