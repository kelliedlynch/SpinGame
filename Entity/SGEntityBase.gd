extends Node2D
class_name SGEntityBase

# Base class for all game entities.

var color: Color = Color.WHITE
var _initialized = false
var texture: Texture2D
@onready var tex_offset = Vector2(randi_range(300, 1000), randi_range(300, 1000))
@onready var tex_scale = Vector2.ONE
#@onready var tex_offset = Vector2.ZERO
#@onready var tex_scale = Vector2(randf_range(1.5, 1.8), randf_range(1.5, 1.8))

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

func update_all_polygons(polygons: Array) -> void:
	for child in get_children():
		update_polygons(child, polygons)

func update_polygons(component, polygons: Array) -> void:
	_initialized = true
	var child_type = "CollisionPolygon2D"
	if component is VisibleArea:
		child_type = "Polygon2D"
	for child in component.get_children():
		if child.get_class() == child_type:
			child.queue_free()
				#component.remove_child(child)
	for poly in polygons:
		_make_new_shape(poly, child_type, component)
		#var n = ClassDB.instantiate(child_type)
		#n.polygon = poly
		#if child_type == "Polygon2D":
			#n.color = color
		#component.add_child(n)
	#emit_signal("polygons_updated", component)
	
func _make_new_shape(poly, child_type, component):
	var n = ClassDB.instantiate(child_type)
	n.polygon = poly
	if child_type == "Polygon2D":
		if texture != null:
			#texture = load("res://wood_01.jpg")
			n.texture = texture
			n.texture_offset = tex_offset
			n.texture_scale = tex_scale
			#n.texture = texture
			
		n.color = color
		#n.scale = entity_scale
	#component.add_child(n)
	component.call_deferred("add_child", n)
	pass
