extends Area2D
class_name Destructor

@onready var parent = get_parent()

# { next_frame: current_frame }
# if current has key, shape is a next frame prediction
var current_for = {}
# { current_frame: next_frame }
# if next has key, shape is the actual destructor
var next_for = {}

var cut_state = CutState.READY
enum CutState{
	CUTTING,
	READY,
	NOT_READY
}
var cut_spin_threshold: float = 1
var cut_velocity_threshold: float = 80
var target: DestructibleEntity = null

# TODO: probably only Player destructor will be affected by spin; break out into
#       separate class
var max_spin_speed = 10
var min_spin_speed = 1
var spin_speed = 3
var spin_accel = 1.7

# extra margin added to destructor shape to prevent it getting stuck
var EXPAND_CAPSULE = .03

func _ready() -> void:
	monitorable = true
	monitoring = false
	child_entered_tree.connect(_on_child_added)
	child_exiting_tree.connect(_on_child_removed)
	#collision_mask = 1 & 10

func _on_child_added(node: Node2D):
	if node is CollisionPolygon2D and !current_for.has(node):
		var next_frame = node.duplicate()
		next_for[node] = next_frame
		current_for[next_frame] = node
		#var shape = CollisionShape2D.new()
		#var next_frame = CapsuleShape2D.new()
		#next_frame.height = 400
		#next_frame.radius = 50
		#shape.shape = next_frame
		add_child(next_frame)

func _on_child_removed(node: Node2D):
	if node is CollisionPolygon2D and !current_for.has(node):
		var next_frame = next_for[node]
		next_for.erase(node)
		current_for.erase(next_frame)
		#remove_child(next_frame)
		next_frame.queue_free()

#func _on_destroyed_material(d: Destructor, mat: DestructibleEntity):
	#await get_tree().physics_frame
	#var pre_velocity = parent.linear_velocity
	#parent.linear_velocity -= parent.linear_velocity * Vector2(mat.material_resistance, mat.material_resistance)
	#var velocity = parent.linear_velocity
	#parent.get_parent().spin_speed -= mat.material_resistance
func get_next_frame_destructor(vel: Vector2, delta: float) -> Array[PackedVector2Array]:
	var next: Array[PackedVector2Array] = []
	for child in get_children():
		if child is CollisionPolygon2D and next_for.has(child):
			var speed = vel.length()
			var travel_angle = vel.angle()
			var poly_size = PolygonMath.size_of_polygon(child.polygon)
			var length = (poly_size.x + speed * delta) * (1 + EXPAND_CAPSULE)
			var radius = poly_size.x / 2 * (1 + EXPAND_CAPSULE / 2)
			var capsule = PolygonMath.generate_capsule_shape(length, radius)
			var rotated = PolygonMath.rotate_polygon(capsule, rad_to_deg(travel_angle))
			var translated = PackedVector2Array()
			var offset = Vector2.from_angle(travel_angle) * (speed * delta + length / 2 - radius)
			for pt in rotated:
				translated.append(pt + offset)
			next.append(translated)
			var vis = Polygon2D.new()
			vis.polygon = translated
			vis.color = Color(.7, .9, .1, .4)
			parent.visible_area.add_child(vis)
	return next
			

func _physics_process(delta: float) -> void:
	spin_speed += spin_accel * delta
	spin_speed = clamp(spin_speed, min_spin_speed, max_spin_speed)
	#var velocity = parent.linear_velocity
	#var speed = velocity.length()
	#for current_frame in next_for:
		#var travel_angle = velocity.angle()
		#var poly_size = PolygonMath.size_of_polygon(current_frame.polygon)
		#var length = poly_size.x + 8
		#if speed > 1000:
			#pass
		##var applied_speed = speed + parent.input_vector.length()
		##if applied_speed > 1:
			##length += min(3, 10/applied_speed) * speed * delta
		#var capsule = PolygonMath.generate_capsule_shape(length, poly_size.x / 2 + 1)
		#var rotated = PolygonMath.rotate_polygon(capsule, rad_to_deg(travel_angle))
		#var translated = PackedVector2Array()
		#var offset = (Vector2.from_angle(travel_angle) * speed).limit_length(length - poly_size.x)
		#for pt in rotated:
			#translated.append(pt + offset)
		#next_for[current_frame].polygon = translated
		#next_for[current_frame].position = current_frame.position

func _translate_to_destructible_space(entity:DestructibleEntity, polys: Array[PackedVector2Array] = []) -> Array[PackedVector2Array]:
	if polys.is_empty():
		for poly in get_children():
			if !(poly is CollisionPolygon2D) or next_for.has(poly): continue
			#if !(poly is CollisionPolygon2D): continue
			polys.append(poly.polygon)	
	var translated: Array[PackedVector2Array] = []
	for poly in polys:
		var new_poly: PackedVector2Array = []
		for pt in poly:
			new_poly.append(entity.destructible_area.to_local((to_global(pt))))
		translated.append(new_poly)
	return translated

func apply_destructor_to_destructible(entity: DestructibleEntity, polys: Array[PackedVector2Array] = []) -> Array[PackedVector2Array]:
	#print(cutting_power())
	var translated = _translate_to_destructible_space(entity, polys)
	# TODO: look at physicsserver2d shapes for this instead. currently just expanding hitbox to ensure
	#       player doesn't get trapped
	var offset: Array[PackedVector2Array] = []
	for poly in translated:
		var expanded = Geometry2D.offset_polygon(poly, 1)
		offset.append_array(expanded)
		
	var destructible = entity.get_polygons(entity.destructible_area)
	#var polys_after_destruction: Array[PackedVector2Array] = []
	var any_overlap = false
	
	var clipped: Array[PackedVector2Array] = []
	for existing_poly in destructible:
		for destruct_poly in offset:
			var overlap = Geometry2D.intersect_polygons(existing_poly, destruct_poly)
			if overlap.is_empty():
				clipped.append(existing_poly)
				continue
			any_overlap = true
			var overlap_vertices: PackedVector2Array = []
			for i in overlap.size():
				overlap_vertices.append_array(overlap[i])
			var clipper: Array[PackedVector2Array] = []
			var frag_shape = entity._get_fragment()
			var fragment_quantity = min(overlap_vertices.size(), entity.material_chunk_quantity)
			var edge_fragments: Array[PackedVector2Array] = []
			for i in fragment_quantity:
				var rotated = PolygonMath.rotate_polygon(frag_shape, randi_range(0, 360))
				for j in rotated.size():
					rotated[j] += overlap_vertices[i]
				edge_fragments.append(rotated)
			var with_edges: Array[PackedVector2Array] = [destruct_poly]
			with_edges.append_array(edge_fragments)
			var final_destructor := PolygonMath.merge_recursive(with_edges)
			var after_clip: Array[PackedVector2Array] = []
			for poly in final_destructor:
				after_clip.append_array(Geometry2D.clip_polygons(existing_poly, poly))
				if after_clip.is_empty():
					pass
			var final_merged = PolygonMath.merge_recursive(after_clip)
			if !final_merged.is_empty():
				var pt = overlap_vertices[randi_range(0, overlap_vertices.size() - 1)]
				var loc = entity.to_global(pt)
				var center = parent.get_parent().to_global(parent.position)
				entity.generate_fragments(1, loc, parent.linear_velocity, center)
			clipped.append_array(final_merged)

	if any_overlap == false: 
		# TODO: Figure out what we actually do when there's no overlap. Sparks?
		return destructible
	spin_speed -= entity.material_resistance
	#var merged: Array[PackedVector2Array] = [clipped[0]]	
	#for poly in clipped:
		#var new_merged: Array[PackedVector2Array] = []
		#for i in randi_range(1, merged.size()):
			#new_merged.append_array(Geometry2D.merge_polygons(merged[i], poly))
	
	return PolygonMath.merge_recursive(clipped)

func cutting_power() -> float:
	var speed = spin_speed
	if parent.linear_velocity.length() > 500:
		speed += parent.linear_velocity.length() / 500
	return speed
