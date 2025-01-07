extends Area2D
class_name SGPolygonAreaBase

# Base class for components that consist of a number of polygons

var _queued_polygon_change: Array[PackedVector2Array] = []

var _polygons: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON]
var polygons: Array[PackedVector2Array]:
	get:
		return _polygons
	set(value):
		_polygons = value
		_queued_polygon_change = value

func _ready() -> void:
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2
	_replace_polygons(_polygons)

func _replace_polygons(poly: Array[PackedVector2Array]):
	for child in get_children():
		if child is Polygon2D or child is CollisionPolygon2D:
			call_deferred("remove_child", child)
	for polygon in poly:
		var p = Polygon2D.new() if self is VisibleArea else CollisionPolygon2D.new()
		p.polygon = polygon
		add_child(p)
	#polygons = poly

func _process(_delta: float) -> void:
	if _queued_polygon_change.is_empty() == false:
		var q = _queued_polygon_change.duplicate()
		_queued_polygon_change.clear()
		_replace_polygons(q)
