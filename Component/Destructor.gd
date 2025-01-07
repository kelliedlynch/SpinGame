extends SGPolygonAreaBase
class_name Destructor

# power is a multiplier added to destruction calculations; most of the time player power is based on angular and linear velocity
var power = 1

static func new(poly: Array[PackedVector2Array]) -> Destructor:
	var n = preload("res://Component/Destructor.tscn").instantiate()
	n.polygons = poly
	return n

func _ready() -> void:
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2
	monitoring = true
	

func _on_area_entered(_node):
	print(_node)

func _on_body_entered(_node):
	print("body entered")
