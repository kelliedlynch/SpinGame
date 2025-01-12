extends Area2D
class_name Destructor

@onready var parent = get_parent()

# { next_frame: current_frame }
# if current has key, shape is a next frame prediction
var current_for = {}
# { current_frame: next_frame }
# if next has key, shape is the actual destructor
var next_for = {}

var cut_state = CutState.NOT_READY
var last_cut_state = CutState.NOT_READY
enum CutState{
	CUTTING,
	READY,
	NOT_READY
}
var cut_spin_threshold: float = 1
var cut_velocity_threshold: float = 80
var target: DestructibleEntity = null

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
	var spin = parent.get_parent().spin_speed
	var velocity = parent.linear_velocity
	last_cut_state = cut_state
	if cut_state != CutState.NOT_READY and (spin < cut_spin_threshold or velocity.length() < cut_velocity_threshold):
		cut_state = CutState.NOT_READY
		for current_frame in next_for:
			next_for[current_frame].position = current_frame.position
			next_for[current_frame].scale = current_frame.scale
	else:
		if cut_state == CutState.NOT_READY and spin >= cut_spin_threshold and velocity.length() >= cut_velocity_threshold:
			cut_state = CutState.READY
		var next_frame_transform = velocity * delta * (1 + spin / 10)
		var next_frame_scale = parent.get_parent().entity_scale * (1 + spin / 100)
		for current_frame in next_for:
			var next_frame = next_for[current_frame]
			#next_frame.position = current_frame.position + next_frame_transform
			#next_frame.scale = next_frame_scale
			next_frame.position = current_frame.position + velocity * delta

func _translate_to_destructible_space(entity:DestructibleEntity) -> Array[PackedVector2Array]:
	var translated: Array[PackedVector2Array] = []
	for poly in get_children():
		if !(poly is CollisionPolygon2D) or next_for.has(poly): continue
		var new_poly: PackedVector2Array = []
		for pt in poly.polygon:
			new_poly.append(entity.destructible_area.to_local((poly.to_global(pt))))
		translated.append(new_poly)
	return translated

func apply_destructor_to_destructible(entity: DestructibleEntity) -> Array[PackedVector2Array]:
	var translated = _translate_to_destructible_space(entity)
	var destructible = entity.get_polygons(entity.destructible_area)
	var polys_after_destruction: Array[PackedVector2Array] = []
	var any_overlap = false
	
	var clipped: Array[PackedVector2Array] = []
	for existing_poly in destructible:
		for destruct_poly in translated:
			var overlap = Geometry2D.intersect_polygons(existing_poly, destruct_poly)
			if overlap.is_empty():
				polys_after_destruction.append(existing_poly)
				continue
			any_overlap = true
			var overlap_vertices: PackedVector2Array = []
			for i in overlap.size():
				overlap_vertices.append_array(overlap[i])
			
			var frag_shape = entity._get_fragment()
			var fragment_quantity = min(overlap_vertices.size(), entity.material_chunk_quantity)
			var edge_fragments: Array[PackedVector2Array] = []
			for i in fragment_quantity:
				var rotated = PolygonMath.rotate_polygon(frag_shape, randi_range(0, 360))
				for j in rotated.size():
					rotated[j] += overlap_vertices[i]
				edge_fragments.append(rotated)
			destruct_poly.append_array(edge_fragments)
			destruct_poly = PolygonMath.merge_recursive(destruct_poly)
				
			clipped.append_array(Geometry2D.clip_polygons(existing_poly, destruct_poly))

	if any_overlap == false: 
		# TODO: Figure out what we actually do when there's no overlap. Sparks?
		return destructible
	return PolygonMath.merge_recursive(clipped)
