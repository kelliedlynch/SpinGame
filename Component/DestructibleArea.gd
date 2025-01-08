extends Area2D
class_name DestructibleArea

var _queued_render_change: bool = false

var _polygons: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON]
var polygons: Array[PackedVector2Array]:
	get:
		return _polygons
	set(value):
		_polygons = value
		_queued_render_change = true

static func create_new(poly: Array[PackedVector2Array]) -> DestructibleArea:
	var n = DestructibleArea.new()
	n.polygons = poly
	return n

func _ready() -> void:
	monitoring = true
	_update_render_objects()

func _update_render_objects():
	for child in get_children():
		if child is CollisionPolygon2D:
			call_deferred("remove_child", child)
	for polygon in polygons:
		var p = CollisionPolygon2D.new()
		p.polygon = polygon
		add_child(p)
	#polygons = poly

func _process(_delta: float) -> void:
	if _queued_render_change == true:
		call_deferred("_update_render_objects")
		_queued_render_change = false
