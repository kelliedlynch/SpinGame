extends CollisionPolygon2D
class_name SGCollPoly

@onready var visible_polygon: Polygon2D = get_children()[0]

func _ready() -> void:
	item_rect_changed.connect(_on_rect_changed)
	
func _on_rect_changed() -> void:
	print("rect change")
