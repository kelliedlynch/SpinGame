extends Area2D
class_name Destructor

var cut_state: CutState = CutState.READY:
	set(value):
		cut_state_changed.emit(cut_state, value)
		cut_state = value
signal cut_state_changed

var target: DestructibleHitbox = null

var base_power: int = 1

# extra margin added to destructor shape to prevent it getting stuck
var EXPAND_CAPSULE = .03

func _ready() -> void:
	monitorable = true
	#monitoring = false
	
func get_next_frame_destructor(travel: Vector2) -> Array[PackedVector2Array]:
	# returns a polygon in global coordinates
	var next: Array[PackedVector2Array] = []
	for child in get_children():
		if child is CollisionPolygon2D:
			#var speed = vel.length()
			var travel_angle = travel.angle()
			var poly_size = PolygonMath.size_of_polygon(child.polygon)
			
			var radius = max(poly_size.x, poly_size.y) / 2
			var r_expansion = radius * EXPAND_CAPSULE
			radius += r_expansion
			var length = (travel.length() + max(poly_size.x, poly_size.y)) - r_expansion * 2
			var capsule = PolygonMath.generate_capsule_shape(length, radius)
			var rotated = PolygonMath.rotate_polygon(capsule, int(rad_to_deg(travel_angle)))
			var translated = PackedVector2Array()
			var offset = Vector2.from_angle(travel_angle) * ((length - poly_size.x) / 2)
			for pt in rotated:
				translated.append(get_parent().to_global(pt + offset))
			next.append(translated)
			#var vis = Polygon2D.new()
			#vis.polygon = translated
			#vis.color = Color(.7, .9, .1, .4)
			#get_tree().root.add_child(vis)
	return next

#func _translate_to_destructible_space(entity:DestructibleEntity, polys: Array[PackedVector2Array] = []) -> Array[PackedVector2Array]:
	#if polys.is_empty():
		#for poly in get_children():
			#if !(poly is CollisionPolygon2D): continue
			##if !(poly is CollisionPolygon2D): continue
			#polys.append(poly.polygon)	
	#var translated: Array[PackedVector2Array] = []
	#for poly in polys:
		#var new_poly: PackedVector2Array = []
		#for pt in poly:
			#new_poly.append(entity.hitbox.to_local((to_global(pt))))
		#translated.append(new_poly)
	#return translated

func get_power() -> float:
	return base_power

enum CutState{
	CUTTING,
	READY,
	NOT_READY,
	BEGIN_CUT,
	END_CUT
}
