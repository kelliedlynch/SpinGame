extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size = get_viewport_rect().size
	monitoring = false
	monitorable = false
	var coll = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	coll.shape = shape
	coll.transform.origin = size / 2
	#shape_owner_add_shape(0, shape)
	add_child(coll)	
	gravity = 0
	linear_damp = 6
