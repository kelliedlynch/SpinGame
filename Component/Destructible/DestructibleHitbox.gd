extends AnimatableBody2D
class_name DestructibleHitbox

# TODO: these should probably not be an absolute size; should probably calculate based on rendered size
#		because polygons can be any size and are scaled when rendered
var material_chunk_size = Vector2(20, 20)
var spark_size = Vector2(8, 8)
# multiplier based on screen size; min length of side when simplifying polygon
var SIMPLIFY_THRESHOLD = .005
# multiplier based on screen size; chunks smaller than this will just vanish
var PRUNE_THRESHOLD = .007
# chunks smaller than this will break off and decay
var DECAY_THRESHOLD = .015

# When generating sparks, look for a point on destructible polygon that's within this distance of
# a point on destructor polygon
var SPARK_DISTANCE = 30
# move the spark-generating point a rancom number of vertices up to this
# TODO: Generate spark point more elegantly, probably using angles and stuff
var SPARK_VERTEX_DRIFT = 4

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 6

const CUT_INERTIA = .1
var material_hardness = 3
var material_resistance = .2
var material_max_cut_speed = 200
var material_linear_damp = 30

var boss: BossMonster

#signal shape_destroyed

func _ready() -> void:
	for child in get_children():
		if child is SGCollPoly:
			#child.tree_exited.connect(_on_child_exited_tree)
			child.visible_polygon.polygon = child.visible_polygon.uv
			child.polygon = child.visible_polygon.polygon
			call_deferred("_set_color", child.visible_polygon)

func _set_color(poly: Polygon2D) -> void:
	var mat_color = Color.CORNFLOWER_BLUE
	mat_color.a = material_hardness / 10.0
	poly.modulate = poly.color.blend(mat_color)
			
#func _on_child_exited_tree():
	#if get_child_count() == 0:
		#emit_signal("shape_destroyed")

#func _destroy_shape(shape: SGCollPoly) -> void:
	##shape.tree_exited.connect(_on_shape_exited_tree)
	#shape.queue_free()
	#emit_signal("shape_destroyed")

func _on_shape_exited_tree():
	pass
	
func _try_clip(poly: PackedVector2Array, clipper: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var clipped: Array[PackedVector2Array] = []
	var any_clipped = false
	for i in clipper.size():
		var this_clip = Geometry2D.clip_polygons(poly, clipper[i])
		if this_clip.is_empty():
			any_clipped = true
			continue
		elif this_clip.size() == 1 and this_clip[0] == poly:
			clipped.append(this_clip[0])
			continue
		elif this_clip.size() == 1:
			clipped.append(this_clip[0])
			any_clipped = true
		else:
			clipped.append_array(this_clip)
			any_clipped = true
	if any_clipped == true:
		return clipped
	return [poly]
	
func _chunkify_destructor(destructor: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var visible_destructor_shape: Array[PackedVector2Array] = []
	var frag_shape = _get_fragment()
	for poly in destructor:
		var size = poly.size()
		# TODO: this probably shouldn't be strictly based on material chunk qty, because it'll make 
		#		too many chunks if there are multiple destructor polygons
		var step = max(int(float(size) / float(material_chunk_quantity)), 0)
		var merged = poly
		for i in size:
			var rotated = PolygonMath.rotate_polygon(frag_shape, randi_range(0, 360))
			for j in rotated.size():
				rotated[j] += poly[i]
			merged = Geometry2D.merge_polygons(merged, rotated)[0]
			i += step
		visible_destructor_shape.append(merged)
	return visible_destructor_shape
	
func apply_destructor(destructor_polys: Array[PackedVector2Array]) -> bool:
	var screen_size = get_viewport_rect().size
	var min_side_length = max(screen_size.x, screen_size.y) * SIMPLIFY_THRESHOLD
	var hitbox_shapes: Array[SGCollPoly] = []
	for child in get_children():
		if child is SGCollPoly:
			hitbox_shapes.append(child)
	var destructor_polys_to_local: Array[PackedVector2Array] = []
	for poly in destructor_polys:
		var new_poly = PackedVector2Array()
		for pt in poly:
			new_poly.append(hitbox_shapes[0].to_local(pt))
		destructor_polys_to_local.append(new_poly)
		
	var chunkified_destructor = _chunkify_destructor(destructor_polys_to_local)
	var polys_after_destruct: Array[PackedVector2Array] = []
	var clipped_any = false
	for i in chunkified_destructor.size():
		for j in hitbox_shapes.size():
			var clipped_shape = Geometry2D.clip_polygons(hitbox_shapes[j].polygon, chunkified_destructor[i])
			if clipped_shape.is_empty():
				generate_fragment(hitbox_shapes[j], chunkified_destructor[i])
				clipped_any = true
				continue
			if clipped_shape.size() == 1 and clipped_shape[0] == hitbox_shapes[j].polygon:
				polys_after_destruct.append(clipped_shape[0])
				continue
			clipped_any = true
			generate_fragment(hitbox_shapes[j], chunkified_destructor[i])
			polys_after_destruct.append_array(clipped_shape)
	
	if clipped_any == false:
		return false
	
	for i in range(polys_after_destruct.size() - 1, -1, -1):
		if _is_prunable(polys_after_destruct[i]):
			polys_after_destruct.remove_at(i)
		i -= 1
	if polys_after_destruct.is_empty():
		#emit_signal("shape_destroyed")
		queue_free()
		return true

	var simplified_polygons: Array[PackedVector2Array] = []
	for i in polys_after_destruct.size():
		var simp = PolygonMath.simplify_polygon(polys_after_destruct[i], min_side_length)
		simplified_polygons.append(simp)
	
	assert(!simplified_polygons.is_empty())
		
	for i in range(simplified_polygons.size() - 1, -1, -1):
		if _is_prunable(simplified_polygons[i]) == true:
			simplified_polygons.remove_at(i)

	var decayed_polygons: Array[PackedVector2Array] = []
	for i in simplified_polygons.size():
		if _is_decayable(simplified_polygons[i]) == true:
			_decay_chunk(simplified_polygons[i])
			continue
		decayed_polygons.append(simplified_polygons[i])

	if decayed_polygons.is_empty():
		#emit_signal("shape_destroyed")
		queue_free()
		return true
		
	#if decayed_polygons.size() >= 1:
		#collision_poly.set_deferred("polygon", decayed_polygons[0])
		#collision_poly.visible_polygon.set_deferred("polygon", decayed_polygons[0])
	
	#if decayed_polygons.size() > 1:
	#var existing_shapes = hitbox_shapes.size()
	for i in range(0, decayed_polygons.size()):
		#var coll_shape: CollisionPolygon2D
		#if existing_shapes > i:
			#coll_shape = hitbox_shapes[0]
		var new_coll = hitbox_shapes[0].duplicate()
		new_coll.polygon = decayed_polygons[i]
		#new_coll.tree_exited.connect(_on_child_exited_tree)
		var vis = new_coll.get_children()[0]
		vis.polygon = new_coll.polygon
		call_deferred("add_child", new_coll)
	for h in hitbox_shapes:
		h.queue_free()
	if get_child_count() > 2:
		pass
	return true

#func _set_remote_path(remote: RemoteTransform2D, target: SGCollPoly):
	#remote.remote_path = remote.get_path_to(target)

func _is_prunable(poly: PackedVector2Array) -> bool:
	var screen_size = get_viewport_rect().size
	var poly_size = PolygonMath.size_of_polygon(poly)
	var prune_size = max(screen_size.x, screen_size.y) * PRUNE_THRESHOLD
	if poly_size.x < prune_size and poly_size.y < prune_size:
		return true
	var area = prune_size * prune_size * 2
	if poly_size.x < prune_size * 1.5 or poly_size.y < prune_size * 1.5:
		if poly_size.x * poly_size.y < area:
			return true
	return false
	
func _decay_chunk(poly: PackedVector2Array):
	var local_poly = PackedVector2Array()
	for vertex in poly:
		local_poly.append(boss.arena.to_local(get_children()[0].to_global(vertex)))
	_spawn_debris(local_poly)

func _spawn_debris(poly: PackedVector2Array):
	var frag = DebrisFragment.new()
	frag.velocity = Vector2(randi_range(40, 60) * cos(randf_range(0, 6.2)), randi_range(40, 60) * sin(randf_range(0, 6.2)))
	frag.rotate_speed = 0
	frag.timeout *= 2
	frag.color = Color.STEEL_BLUE
	frag.polygon = poly
	boss.arena.add_child(frag)
	
func _is_decayable(poly: PackedVector2Array) -> bool:
	var size = PolygonMath.size_of_polygon(poly)
	var screen = get_viewport_rect().size
	var decay_size = max(screen.x, screen.y) * DECAY_THRESHOLD
	if size.x < decay_size and size.y < decay_size:
		return true
	var area = PolygonMath.area_of_polygon(poly)
	if area < pow(decay_size, 1.5):
		return true
	if size.x < decay_size * 2 or size.y < decay_size * 2:
		return area < pow(decay_size, 2)
	return false

func _get_fragment(size: Vector2 = material_chunk_size):
	# TODO: this will return different fragment shapes depending on material
	return _triangle_fragment(size)	

func _triangle_fragment(size: Vector2):
	var triangle = PackedVector2Array([Vector2(0, -size.y / 2.0), Vector2(size.x / 2.0, size.y / 2.0), Vector2(-size.x / 2.0, size.y / 2.0)])
	return triangle
	
func generate_fragment(collision_poly: SGCollPoly, destructor_poly: PackedVector2Array):
	var closest_vertex = collision_poly.to_global(destructor_poly[0])
	var closest_distance = 1000000
	for vertex in collision_poly.polygon:
		#vertex = collision_poly.to_global(vertex)
		#for poly in destructor_polys:
		var p_size = destructor_poly.size()
		for i in p_size:
			var dist = vertex.distance_to(destructor_poly[i])
			if dist < SPARK_DISTANCE:
				closest_distance = dist
				var index = i + randi_range(0, SPARK_VERTEX_DRIFT)
				if index >= p_size:
					index -= p_size
				closest_vertex = collision_poly.to_global(destructor_poly[index])
				break
			if dist < closest_distance:
				closest_distance = dist
				closest_vertex = collision_poly.to_global(destructor_poly[i])
	assert(closest_distance < SPARK_DISTANCE)
	
	var frag = DebrisFragment.new()
	frag.polygon = _get_fragment(spark_size)
	frag.color = Color.YELLOW
	frag.position = boss.arena.to_local(closest_vertex)
	#var d_size = PolygonMath.size_of_polygon(destructor_poly)
	var min_pt = collision_poly.to_global(PolygonMath.min_point(destructor_poly))
	var max_pt = collision_poly.to_global(PolygonMath.max_point(destructor_poly))
	var center_point = (max_pt - min_pt) / 2 + min_pt
	
	
	var vector_to_tan = closest_vertex - center_point
	var angle_vec = vector_to_tan.angle()
	var rot = angle_vec + PI/2 
	var out_vec = Vector2.from_angle(rot)
	var speed = randi_range(300, 600)
	frag.velocity = out_vec * speed
	boss.arena.add_child(frag)
