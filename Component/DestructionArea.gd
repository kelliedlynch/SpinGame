extends SGPolygonAreaBase
class_name DestructionArea


static func new(poly: Array[PackedVector2Array]) -> HitboxArea:
	var n = preload("res://Component/DestructionArea.tscn").instantiate()
	n.polygons = poly
	return n

func _ready() -> void:
	super._ready()
	monitoring = true
