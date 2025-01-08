extends Node2D
class_name VisibleArea

var _queued_render_change: bool = false

var _polygons: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON]
var polygons: Array[PackedVector2Array]:
	get:
		return _polygons
	set(value):
		_polygons = value
		_queued_render_change = true

static func create_new(poly: Array[PackedVector2Array]) -> VisibleArea:
	var n = VisibleArea.new()
	n.polygons = poly
	return n

func _ready() -> void:
	_update_render_objects()

func _on_scale_changed(s: Vector2):
	scale = s

func _update_render_objects():
	for child in get_children():
		if child is Polygon2D:
			call_deferred("remove_child", child)
	for polygon in polygons:
		var p = Polygon2D.new()
		p.polygon = polygon
		#p.scale = scale
		add_child(p)

func _process(_delta: float) -> void:
	if _queued_render_change == true:
		call_deferred("_update_render_objects")
		_queued_render_change = false
