extends RigidBody2D
class_name RigidHitbox

var _queued_render_change: bool = false

var _polygons: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON]
var polygons: Array[PackedVector2Array]:
	get:
		return _polygons
	set(value):
		_polygons = value
		_queued_render_change = true
		
var _entity_scale: Vector2 = Vector2.ONE
var entity_scale: Vector2:
	get:
		return _entity_scale
	set(value):
		_entity_scale = value
		emit_signal("scale_changed", value)
		
signal scale_changed

func _on_scale_changed(s: Vector2):
	for child in get_children():
		if child is CollisionPolygon2D:
			child.scale = s


static func create_new(poly: Array[PackedVector2Array]) -> RigidHitbox:
	var n = RigidHitbox.new()
	n.polygons = poly
	return n

func _ready() -> void:
	scale_changed.connect(_on_scale_changed)
	_update_render_objects()

func _update_render_objects():
	for child in get_children():
		if child is CollisionPolygon2D:
			call_deferred("remove_child", child)
	for polygon in polygons:
		var p = CollisionPolygon2D.new()
		p.polygon = polygon
		p.scale = entity_scale
		add_child(p)
	

func _process(_delta: float) -> void:
	if _queued_render_change == true:
		#call_deferred("_update_render_objects")
		_update_render_objects()
		_queued_render_change = false
