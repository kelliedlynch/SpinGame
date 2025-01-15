extends SGEntityBase
class_name DestructibleEntity

#@onready var destructible_area: DestructionArea = $DestructionArea
#@onready var destruction_polys: Array[PackedVector2Array] = PolygonMath.polygons_from_children($DestructionArea)
@onready var destructible_area = $DestructibleArea
@onready var visible_area = $VisibleArea
@onready var hitbox = $DestructibleHitbox

# TODO: these should probably not be an absolute size; should probably calculate based on rendered size
#		because polygons can be any size and are scaled when rendered
var material_chunk_size = Vector2(20, 20)
var spark_size = Vector2(8, 8)
# multiplier based on screen size; min length of side when simplifying polygon
var SIMPLIFY_THRESHOLD = .005
# multiplier based on screen size; chunks smaller than this will just vanish
var PRUNE_THRESHOLD = .005
# chunks smaller than this will break off and decay
var DECAY_THRESHOLD = .025

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 6

const CUT_INERTIA = .1
var material_hardness = 2
var material_resistance = .2
var material_max_cut_speed = 200
var material_linear_damp = 30

var active_destructors = {}

signal fragments_created
signal was_destroyed
signal destructible_area_clipped
signal destructor_destroyed_material

func _init():
	color = Color.DODGER_BLUE

func _ready() -> void:
	was_destroyed.connect(_on_was_destroyed)
	super._ready()

func _on_was_destroyed(node):
	queue_free()
	
func apply_destructor(destruct_area: Array[PackedVector2Array]) -> bool:
	var screen_size = get_viewport_rect().size
	var min_side_length = max(screen_size.x, screen_size.y) * SIMPLIFY_THRESHOLD
	var before_destruct = get_polygons(hitbox)
	var destruct_area_to_local: Array[PackedVector2Array] = []
	for poly in destruct_area:
		var new_poly = PackedVector2Array()
		for pt in poly:
			new_poly.append(hitbox.to_local(pt))
		destruct_area_to_local.append(new_poly)
		
	var any_clipped = false
	for h in before_destruct:
		for c in destruct_area_to_local:
			if Geometry2D.intersect_polygons(h, c).is_empty():
				continue
			any_clipped = true
			break
		if any_clipped == true: break
	if any_clipped == false: return any_clipped
	
	
	#var hitbox_after_destruct = PolygonMath.clip_multiple(before_destruct, destruct_area_to_local, true)
	var hitbox_after_initial_destruct: Array[PackedVector2Array] = []
	for i in before_destruct.size():
		var clipped_i: Array[PackedVector2Array] = []
		for j in destruct_area_to_local.size():
			var clipped = Geometry2D.clip_polygons(before_destruct[i], destruct_area_to_local[j])
			if clipped.is_empty():
				continue
			clipped_i.append_array(clipped)
		var size = clipped_i.size()
		if size == 0:
			continue
		hitbox_after_initial_destruct.append_array(clipped_i)
	
	if hitbox_after_initial_destruct.is_empty():
		emit_signal("was_destroyed", self)
		return any_clipped
	
	var hitbox_after_destruct: Array[PackedVector2Array] = []
	for i in hitbox_after_initial_destruct.size():
		if _is_prunable(hitbox_after_initial_destruct[i]):
			continue
		hitbox_after_destruct.append(hitbox_after_initial_destruct[i])
	
	if hitbox_after_destruct.is_empty():
		emit_signal("was_destroyed", self)
		return any_clipped
		
	var visible_destructor_shape: Array[PackedVector2Array] = []
	var frag_shape = _get_fragment()
	for poly in destruct_area_to_local:
		var size = poly.size()
		# TODO: this probably shouldn't be strictly based on material chunk qty, because it'll make 
		#		too many chunks if there are multiple destructor polygons
		var step = max(int(size / material_chunk_quantity), 0)
		var merged = poly
		for i in size:
			var rotated = PolygonMath.rotate_polygon(frag_shape, randi_range(0, 360))
			for j in rotated.size():
				rotated[j] += poly[i]
			merged = Geometry2D.merge_polygons(merged, rotated)[0]
			i += step
		visible_destructor_shape.append(merged)
	#jagged_edges.append_array(destruct_area_to_local)
	#var visible_destructor_shape = PolygonMath.merge_group(jagged_edges)
	#for shape in jagged_edges:
		#var p = Polygon2D.new()
		#p.polygon = shape
		#p.color = Color.CHARTREUSE
		#add_child(p)
	
	var old_visible = get_polygons(visible_area)
	var visible_inside_new_hitbox: Array[PackedVector2Array] = []
	#var new_hitbox_inside_visible: Array[PackedVector2Array] = []
	for i in hitbox_after_destruct.size():
		var intersected = PolygonMath.intersect_multiple([hitbox_after_destruct[i]], old_visible)
		if intersected.is_empty():
			continue
		#var simp = PolygonMath.simplify_polygon(intersected, min_side_length)
		# TODO: IS SIMPLIFYING NEEDED HERE?
		for poly in intersected:
			if _is_prunable(poly):
				continue
			visible_inside_new_hitbox.append(poly)
		#visible_inside_new_hitbox.append_array(intersected)
		#new_hitbox_inside_visible.append_array(simp)
	
	assert(visible_inside_new_hitbox.size() == hitbox_after_destruct.size())
	
	if visible_inside_new_hitbox.is_empty():
		emit_signal("was_destroyed", self)
		return any_clipped
	
	#var visible_after_destruct: Array[PackedVector2Array] = []
	for i in visible_inside_new_hitbox.size():
		#var clipped = PolygonMath.clip_multiple([visible_inside_new_hitbox[i]], visible_destructor_shape, true)
		var clipped_i: Array[PackedVector2Array] = []
		for j in visible_destructor_shape.size():
			var clipped = Geometry2D.clip_polygons(visible_inside_new_hitbox[i], visible_destructor_shape[j])
			if clipped.is_empty():
				continue
			clipped_i.append_array(clipped)
		var size = clipped_i.size()
		if size == 0:
			continue
		#visible_after_destruct.append_array(clipped_i)
			
			
		if size != 1:
			visible_inside_new_hitbox[i].clear()
			hitbox_after_destruct[i].clear()
		if size > 1:
			for j in clipped_i.size():
				var new_chunk = PolygonMath.simplify_polygon(clipped_i[j], min_side_length)
				visible_inside_new_hitbox.append(new_chunk)
				hitbox_after_destruct.append(new_chunk)
		elif size == 1:
			visible_inside_new_hitbox[i] = PolygonMath.simplify_polygon(clipped_i[0], min_side_length)
			#hitbox_after_destruct[i] = clipped[0]
	
	#var simplified_hitbox: Array[PackedVector2Array] = []
	#var simplified_visible: Array[PackedVector2Array] = []
	#for i in hitbox_after_destruct.size():
		#if hitbox_after_destruct[i].is_empty() == true:
			#continue
		#simplified_hitbox.append(PolygonMath.simplify_polygon(hitbox_after_destruct[i], min_side_length))
		#simplified_visible.append(PolygonMath.simplify_polygon(visible_inside_new_hitbox[i], min_side_length))
	#
	#assert(!simplified_hitbox.is_empty())
		
	for i in hitbox_after_destruct.size():
		if _is_prunable(hitbox_after_destruct[i]) == true or _is_prunable(visible_inside_new_hitbox[i]) == true:
			hitbox_after_destruct[i].clear()
			visible_inside_new_hitbox[i].clear()

	var decayed_hitbox: Array[PackedVector2Array] = []
	var decayed_visible: Array[PackedVector2Array] = []
	for i in hitbox_after_destruct.size():
		if hitbox_after_destruct[i].is_empty() == true:
			continue
		if _is_decayable(hitbox_after_destruct[i]) == true or _is_decayable(visible_inside_new_hitbox[i]) == true:
			_decay_chunk(visible_inside_new_hitbox[i])
			continue
		decayed_hitbox.append(hitbox_after_destruct[i])
		decayed_visible.append(visible_inside_new_hitbox[i])

	if decayed_hitbox.is_empty():
		emit_signal("was_destroyed", self)
		return any_clipped

	call_deferred("update_polygons", hitbox, decayed_hitbox)
	call_deferred("update_polygons", destructible_area, decayed_hitbox)
	call_deferred("update_polygons", visible_area, decayed_visible)
	return any_clipped

	
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
		local_poly.append(get_parent().to_local(destructible_area.to_global(vertex)))
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
	
func generate_fragment(pos: Vector2, travel_vec: Vector2, center: Vector2):

	var frag = DebrisFragment.new()
	frag.polygon = _get_fragment(spark_size)
	frag.color = Color.YELLOW
	frag.position = pos
	var vector_to_tan = pos - center
	var angle_diff = vector_to_tan.angle_to(travel_vec)
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
