extends Area2D
class_name Destructor

@onready var destruct_polygon: CollisionPolygon2D = $DestructPolygon
var clipper_quantity = 5
# size is how big the fragments should be, relative to size of destructor
var clipper_size = .3

func _ready() -> void:
	monitoring = true
	#area_entered.connect(_on_area_entered)
	#body_entered.connect(_on_body_entered)
	

func _on_area_entered(_node):
	print(_node)

func _on_body_entered(_node):
	print("body entered")
