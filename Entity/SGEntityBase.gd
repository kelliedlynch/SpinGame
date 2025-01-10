extends Node2D
class_name SGEntityBase

# Base class for all game entities.

var entity_scale: Vector2 = Vector2.ONE
var color: Color = Color.WHITE
var _initialized = false

signal polygons_updated

#func _init() -> void:
	#update_all_polygons(PolygonMath.DEFAULT_POLYGON)

func _ready() -> void:
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2
	if _initialized == false:
		update_all_polygons([PolygonMath.DEFAULT_POLYGON])


func get_polygons(component) -> Array[PackedVector2Array]:
	var p: Array[PackedVector2Array] = []
	for child in component.get_children():
		if child is CollisionPolygon2D or child is Polygon2D:
			p.append(child.polygon)
	return p

func update_all_polygons(polygons: Array[PackedVector2Array]) -> void:
	for child in get_children():
		update_polygons(child, polygons)

func update_polygons(component, polygons: Array[PackedVector2Array]) -> void:
	_initialized = true
	var child_type = "CollisionPolygon2D"
	if component is VisibleArea:
		child_type = "Polygon2D"
	for child in component.get_children():
		if child.get_class() == child_type:
			component.remove_child(child)
	for poly in polygons:
		var n = ClassDB.instantiate(child_type)
		n.polygon = poly
		if child_type == "Polygon2D":
			n.color = color
		component.add_child(n)
	_update_scale(self, entity_scale)
	emit_signal("polygons_updated", component)

func update_scale(s: Vector2) -> void:
	_update_scale(self, s)
	
func _update_scale(entity, s: Vector2):
	for child in entity.get_children():
		if child is CollisionObject2D:
			_update_scale(child, s)
		elif child is CollisionPolygon2D:
			child.scale = s
		elif child is VisibleArea:
			child.scale = s
