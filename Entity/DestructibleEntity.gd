extends SGEntityBase
class_name DestructibleEntity

#@onready var destructible_area: DestructionArea = $DestructionArea
#@onready var destruction_polys: Array[PackedVector2Array] = PolygonMath.polygons_from_children($DestructionArea)
#@onready var destructible_area = $DestructibleArea
#@onready var visible_area = $VisibleArea
@onready var hitbox = $Hitbox

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

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 6

const CUT_INERTIA = .1
var material_hardness = 3
var material_resistance = .2
var material_max_cut_speed = 200
var material_linear_damp = 30



 
signal was_destroyed
#signal shape_was_destroyed


#func _init():
	#notification(NOTIFICATION_SCENE_INSTANTIATED).connect(_on_instantiated)
	#color = Color.DODGER_BLUE
#func _notification(what):
	#if what == NOTIFICATION_SCENE_INSTANTIATED:
		#for child in hitbox.get_children():
			#if child is SGCollPoly:
				##child.tree_exiting.connect(_on_shape_was_destroyed.bind(child))
				#child.visible_polygon.polygon = child.visible_polygon.uv
				#child.polygon = child.visible_polygon.uv
	#pass

func _ready() -> void:
	was_destroyed.connect(_on_was_destroyed)
	#shape_was_destroyed.connect(_on_shape_was_destroyed)
	for child in hitbox.get_children():
		if child is SGCollPoly:
			child.tree_exiting.connect(_on_shape_was_destroyed.bind(child))
			child.visible_polygon.polygon = child.visible_polygon.uv
			child.polygon = child.visible_polygon.polygon
			
	#super._ready()

func _on_was_destroyed(_node):
	queue_free()

func _on_shape_was_destroyed(node):
	#node.queue_free()
	if hitbox.get_child_count() == 0:
		emit_signal("was_destroyed", node)
	
func _try_clip(poly: PackedVector2Array, clipper: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var clipped: Array[PackedVector2Array] = []

	#var clipped_i: Array[PackedVector2Array] = []
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
	
func apply_destructor(collision_poly: SGCollPoly, destruct_area: Array[PackedVector2Array]) -> bool:
	var screen_size = get_viewport_rect().size
	var min_side_length = max(screen_size.x, screen_size.y) * SIMPLIFY_THRESHOLD
	var destruct_area_to_local: Array[PackedVector2Array] = []
	for poly in destruct_area:
		var new_poly = PackedVector2Array()
		for pt in poly:
			new_poly.append(collision_poly.to_local(pt))
		destruct_area_to_local.append(new_poly)
	
	#var hitbox_after_initial_destruct = _try_clip(collision_poly.polygon, destruct_area_to_local)
	#
	#if hitbox_after_initial_destruct.is_empty():
		##emit_signal("shape_was_destroyed", collision_poly)
		#collision_poly.queue_free()
		#return true
	#elif hitbox_after_initial_destruct.size() == 1 and hitbox_after_initial_destruct[0] == collision_poly.polygon:
		#return false
	
	var chunkified_destructor = _chunkify_destructor(destruct_area_to_local)
	#var visible_after_destruct: Array[PackedVector2Array] = []
	#for i in visible_inside_new_hitbox.size():
		#var clipped = PolygonMath.clip_multiple([visible_inside_new_hitbox[i]], visible_destructor_shape, true)
	var polys_after_destruct: Array[PackedVector2Array] = []
	for i in chunkified_destructor.size():
		var clipped_hitbox = Geometry2D.clip_polygons(collision_poly.polygon, chunkified_destructor[i])
		#var clipped_visible = Geometry2D.clip_polygons(collision_poly.visible_polygon.polygon, chunkified_destructor[i])
		if clipped_hitbox.is_empty():
			collision_poly.queue_free()
			return true
		polys_after_destruct.append_array(clipped_hitbox)
	#var size = clipped_i.size()
	#if size == 0:
		#continue
	
	for i in range(polys_after_destruct.size() - 1, -1, -1):
		if _is_prunable(polys_after_destruct[i]):
			polys_after_destruct.remove_at(i)
		i -= 1
	if polys_after_destruct.is_empty():
		#emit_signal("shape_was_destroyed", collision_poly)
		collision_poly.queue_free()
		return true
	if polys_after_destruct.size() == 1 and polys_after_destruct[0] == collision_poly.polygon:
		return false

	var simplified_polygons: Array[PackedVector2Array] = []
	for i in polys_after_destruct.size():
		#if hitbox_after_destruct[i].is_empty() == true:
			#continue
		var simp = PolygonMath.simplify_polygon(polys_after_destruct[i], min_side_length)
		simplified_polygons.append(simp)
	
	assert(!simplified_polygons.is_empty())
		
	for i in range(simplified_polygons.size() - 1, -1, -1):
		if _is_prunable(simplified_polygons[i]) == true:
			simplified_polygons.remove_at(i)

	#var decayed_hitbox: Array[PackedVector2Array] = []
	var decayed_polygons: Array[PackedVector2Array] = []
	for i in simplified_polygons.size():
		if _is_decayable(simplified_polygons[i]) == true:
			_decay_chunk(simplified_polygons[i], collision_poly)
			continue
		decayed_polygons.append(simplified_polygons[i])

	if decayed_polygons.is_empty():
		#emit_signal("shape_was_destroyed", collision_poly)
		collision_poly.queue_free()
		return true
		
	if decayed_polygons.size() >= 1:
		collision_poly.set_deferred("polygon", decayed_polygons[0])
		collision_poly.visible_polygon.set_deferred("polygon", decayed_polygons[0])
	
	if decayed_polygons.size() > 1:
		for i in range(1, decayed_polygons.size()):
			var new_coll = collision_poly.duplicate()
			new_coll.polygon = decayed_polygons[i]
			#var new_vis = collision_poly.visible_polygon.duplicate()
			#new_vis.polygon = decayed_visible[i]
			var vis = new_coll.get_children()[0]
			vis.polygon = new_coll.polygon
			#new_coll.add_child(new_vis)
			hitbox.call_deferred("add_child", new_coll)
			#new_coll.owner = collision_poly.owner
			#var a = new_coll.owner
			#var b = collision_poly.owner
			var old_remote = collision_poly.find_remote_transform()
			var new_remote = old_remote.duplicate()
			#new_coll.remote_transform = new_remote
			#var a = collision_poly.remote_transform.scene_file_path
			#new_remote.scene_file_path = .rsplit("/", false, 1)[0].path_join(new_remote.name)
			old_remote.add_sibling(new_remote)
			#new_remote.remote_path = new_remote.get_path_to(new_coll)
			call_deferred("_set_remote_path", new_remote, new_coll)

	return true

func _set_remote_path(remote: RemoteTransform2D, target: SGCollPoly):
	remote.remote_path = remote.get_path_to(target)

	
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
	
func _decay_chunk(poly: PackedVector2Array, collision_poly: SGCollPoly):
	var local_poly = PackedVector2Array()
	for vertex in poly:
		local_poly.append(get_parent().to_local(collision_poly.to_global(vertex)))
	_spawn_debris(local_poly)

func _spawn_debris(poly: PackedVector2Array):
	var frag = DebrisFragment.new()
	frag.velocity = Vector2(randi_range(40, 60) * cos(randf_range(0, 6.2)), randi_range(40, 60) * sin(randf_range(0, 6.2)))
	frag.rotate_speed = 0
	frag.timeout *= 2
	frag.color = Color.STEEL_BLUE
	frag.polygon = poly
	add_sibling(frag)
	
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
	
func generate_fragment(pos: Vector2, _travel_vec: Vector2, center: Vector2):

	var frag = DebrisFragment.new()
	frag.polygon = _get_fragment(spark_size)
	frag.color = Color.YELLOW
	frag.position = pos
	var vector_to_tan = pos - center
	#var angle_diff = vector_to_tan.angle_to(travel_vec)
	#var mult = -1 if angle_diff > 0 else 1
	
	var angle_vec = vector_to_tan.angle()
	var rot = angle_vec + PI/2 
	#var a = travel_vec.angle()
	#
	#var angle = rad_to_deg(travel_vec.angle())
	#angle += 120
	#angle += randi_range(0, 40)
	#var out_vec = Vector2.from_angle(deg_to_rad(angle))

	var out_vec = Vector2.from_angle(rot)
		


	var speed = randi_range(300, 600)
	#print(Vector2.from_angle(offset))
	frag.velocity = out_vec * speed
	add_sibling(frag)
	
func _process(_delta: float) -> void:
	pass

func calculate_size() -> Vector2:
	var min_x = 1000000
	var max_x = 0
	var min_y = 1000000
	var max_y = 0
	for poly in hitbox.get_children():
		if poly is CollisionPolygon2D:
			for vertex in poly.polygon:
				var v = poly.to_global(vertex)
				if v.x < min_x: min_x = v.x
				if v.y < min_y: min_y = v.y
				if v.x > min_x: max_x = v.x
				if v.y > min_y: max_y = v.y
	return Vector2(max_x - min_x, max_y - min_y)
			
