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
var min_spin_speed = .1
var spin_speed = 1
var spin_accel = .7

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

func _on_destroyed_material(d: Destructor, mat: DestructibleEntity):
	await get_tree().physics_frame
	var pre_velocity = parent.linear_velocity
	parent.linear_velocity -= parent.linear_velocity * Vector2(mat.material_resistance, mat.material_resistance)
	var velocity = parent.linear_velocity
	parent.get_parent().spin_speed -= mat.material_resistance

func _physics_process(delta: float) -> void:
	spin_speed += spin_accel * delta
	spin_speed = clamp(spin_speed, min_spin_speed, max_spin_speed)
	var velocity = parent.linear_velocity
	for current_frame in next_for:
		var poly_size = PolygonMath.size_of_polygon(current_frame.polygon)
		var length = poly_size.x + velocity.length() * delta
		var capsule = PolygonMath.generate_capsule_shape(length, poly_size.x / 2)
		var rotated = PolygonMath.rotate_polygon(capsule, rad_to_deg(velocity.angle()))
		var translated = PackedVector2Array()
		var offset = velocity * delta
		for pt in rotated:
			translated.append(pt + offset)
		next_for[current_frame].polygon = translated
		next_for[current_frame].position = current_frame.position
		next_for[current_frame].scale = current_frame.scale
		
	#if cut_state != CutState.NOT_READY and (spin < cut_spin_threshold or velocity.length() < cut_velocity_threshold):
		##cut_state = CutState.NOT_READY
		#for current_frame in next_for:
			#next_for[current_frame].position = current_frame.position
			#next_for[current_frame].scale = current_frame.scale
	#else:
		##if cut_state == CutState.NOT_READY and spin >= cut_spin_threshold and velocity.length() >= cut_velocity_threshold:
			##cut_state = CutState.READY
		#var next_frame_transform = velocity * delta * (1 + spin / 10)
		#var next_frame_scale = parent.get_parent().entity_scale * (1 + spin / 100)
		#for current_frame in next_for:
			#var next_frame = next_for[current_frame]
			##next_frame.position = current_frame.position + next_frame_transform
			##next_frame.scale = next_frame_scale
			#next_frame.position = current_frame.position + velocity * delta

func _translate_to_destructible_space(entity:DestructibleEntity) -> Array[PackedVector2Array]:
	var translated: Array[PackedVector2Array] = []
	for poly in get_children():
		if !(poly is CollisionPolygon2D) or next_for.has(poly): continue
		#if !(poly is CollisionPolygon2D): continue
		var new_poly: PackedVector2Array = []
		for pt in poly.polygon:
			new_poly.append(entity.destructible_area.to_local((poly.to_global(pt))))
		translated.append(new_poly)
	return translated

func apply_destructor_to_destructible(entity: DestructibleEntity) -> Array[PackedVector2Array]:
	#print(cutting_power())
	var translated = _translate_to_destructible_space(entity)
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
			#var final_merged = PolygonMath.merge_recursive(final)
			clipped.append_array(final_merged)

	if any_overlap == false: 
		# TODO: Figure out what we actually do when there's no overlap. Sparks?
		return destructible
	
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
