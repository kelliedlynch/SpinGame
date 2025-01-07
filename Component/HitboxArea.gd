extends SGPolygonAreaBase
class_name HitboxArea

static func new(poly: Array[PackedVector2Array]) -> HitboxArea:
	var n = preload("res://Component/HitboxArea.tscn").instantiate()
	n.polygons = poly
	return n
