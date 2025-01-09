extends Node2D
class_name VisibleArea

static func create_new(poly: Array[PackedVector2Array]) -> VisibleArea:
	var n = VisibleArea.new()
	n.polygons = poly
	return n
