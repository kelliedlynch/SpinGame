extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size = get_viewport_rect().size
	
	var coll = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	coll.shape = shape
	coll.transform.origin = size / 2
	#shape_owner_add_shape(0, shape)
	add_child(coll)
	
	
	gravity = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
