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
# multiplier based on screen size; min length of side when simplifying polygon
var SIMPLIFY_THRESHOLD = .005
# multiplier based on screen size; chunks smaller than this will just vanish
var PRUNE_THRESHOLD = .005
# chunks smaller than this will break off and decay
var DECAY_THRESHOLD = .025

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 6

const CUT_INERTIA = .1
var material_hardness = 8
var material_resistance = .1
var material_max_cut_speed = 300
var material_linear_damp = 20

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
	var destroyed_any = false
	var screen_size = get_viewport_rect().size
	var min_side_length = max(screen_size.x, screen_size.y) * SIMPLIFY_THRESHOLD
	var before_destruct = get_polygons(hitbox)
	var destruct_area_to_local: Array[PackedVector2Array] = []
	for poly in destruct_area:
		var new_poly = PackedVector2Array()
		for pt in poly:
			new_poly.append(hitbox.to_local(pt))
		destruct_area_to_local.append(new_poly)
			
	var after_destruct = PolygonMath.clip_multiple(before_destruct, destruct_area_to_local)
	#var after_destruct = PolygonMath.clip_multiple(before_destruct, removed)
	if after_destruct.is_empty():
		destroyed_any = true
		emit_signal("was_destroyed", self)
		return true
	
	var simplified_hitbox: Array[PackedVector2Array] = []
	for poly in after_destruct:
		var simplified = PolygonMath.simplify_polygon(poly, min_side_length)
		if simplified.size() == 0:
			pass
		simplified_hitbox.append(simplified)
		
	var cut_edges = PolygonMath.intersect_multiple(before_destruct, destruct_area_to_local)
	var cut_vertices = PackedVector2Array()
	for poly in cut_edges:
		cut_vertices.append_array(poly)
	
	if cut_edges.is_empty():
		return false
		
	var pruned_hitbox: Array[PackedVector2Array] = []
	for poly in simplified_hitbox:
		if _is_prunable(poly) == true:
			continue
		pruned_hitbox.append(poly)
	
	if pruned_hitbox.size() == 0:
		emit_signal("was_destroyed", self)
		return true

	var frag_shape = _get_fragment()
	var fragment_quantity = min(cut_vertices.size(), material_chunk_quantity)
	var edge_fragments: Array[PackedVector2Array] = []
	for i in fragment_quantity:
		var rotated = PolygonMath.rotate_polygon(frag_shape, randi_range(0, 360))
		for j in rotated.size():
			rotated[j] += cut_vertices[i]
		edge_fragments.append(rotated)
	var rough_clipper = PolygonMath.merge_recursive(edge_fragments)
	
	if rough_clipper.is_empty():
		pass
		
	var visible_after_clip: Array[PackedVector2Array] = pruned_hitbox.duplicate(true)
	var new_bits: Array[PackedVector2Array] = []
	for i in pruned_hitbox.size():
		var visible_remainder = PolygonMath.clip_multiple([pruned_hitbox[i]], rough_clipper)
		var v = visible_remainder.size()
		if v == 0:
			destroyed_any = true
			visible_after_clip[i].clear()
			pruned_hitbox[i].clear()
			continue
		if v > 1:
			destroyed_any = true
			pruned_hitbox[i].clear()
			visible_after_clip[i].clear()
			new_bits.append_array(visible_remainder)
			continue
		if visible_remainder[0] != pruned_hitbox[i]:
			destroyed_any = true
		visible_after_clip[i] = visible_remainder[0]
	
	if visible_after_clip.is_empty():
		emit_signal("was_destroyed", self)
		return true
		
	var simplified_visible: Array[PackedVector2Array] = []
	for poly in visible_after_clip:
		if poly.is_empty():
			destroyed_any = true
			continue
		simplified_visible.append(PolygonMath.simplify_polygon(poly, min_side_length))
	
	var simplified_new_bits: Array[PackedVector2Array] = []
	for b in new_bits:
		var simp = PolygonMath.simplify_polygon(b, min_side_length)
		if simp.is_empty(): 
			continue
		if _is_prunable(simp):
			destroyed_any = true
			continue
		simplified_new_bits.append(simp)
	
	var visible_cleaned: Array[PackedVector2Array] = []
	var hitbox_cleaned: Array[PackedVector2Array] = []
	for i in simplified_visible.size():
		if simplified_visible[i].is_empty():
			if !hitbox_cleaned.is_empty():
				# something went wrong, a hitbox poly was lost while visible retained, or vice versa
				pass
			continue
		if _is_prunable(simplified_visible[i]):
			destroyed_any = true
			continue
		if Geometry2D.is_polygon_clockwise(simplified_visible[i]):
			# should this be possible?
			pass
		visible_cleaned.append(simplified_visible[i])
		hitbox_cleaned.append(pruned_hitbox[i])
			
	
	visible_cleaned.append_array(simplified_new_bits)
	hitbox_cleaned.append_array(simplified_new_bits)
	#var new_hitbox = PolygonMath.merge_recursive(pruned_hitbox)

	var after_decay = _decay_chunks(hitbox_cleaned)
	if after_decay.is_empty():
		emit_signal("was_destroyed", self)
		return true
		
	var hitbox_after_decay: Array[PackedVector2Array] = []
	var visible_after_decay: Array[PackedVector2Array] = []
	if after_decay.is_empty():
		emit_signal("was_destroyed", self)
		return true
		
	for i in after_decay.size():
		if after_decay[i].is_empty():
			destroyed_any = true
			continue
		hitbox_after_decay.append(hitbox_cleaned[i])
		visible_after_decay.append(visible_cleaned[i])
	if hitbox_cleaned.is_empty():
		emit_signal("was_destroyed", self)
		return true
	
	call_deferred("update_polygons", hitbox, hitbox_after_decay)
	call_deferred("update_polygons", destructible_area, hitbox_after_decay)
	call_deferred("update_polygons", visible_area, visible_after_decay)
	return destroyed_any

	
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
	
func _decay_chunks(polys: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var decayed: Array[PackedVector2Array] = []
	for i in polys.size():
		if polys[i].is_empty():
			continue
		if _is_decayable(polys[i]) == true:
			var local_poly = PackedVector2Array()
			for vertex in polys[i]:
				local_poly.append(get_parent().to_local(destructible_area.to_global(vertex)))
			_spawn_debris(local_poly)
			decayed.append(PackedVector2Array())
			continue
		decayed.append(polys[i])
	return decayed

func _spawn_debris(poly: PackedVector2Array):
	var frag = DebrisFragment.new()
	frag.velocity = Vector2(randi_range(40, 60) * cos(randf_range(0, 6.2)), randi_range(40, 60) * sin(randf_range(0, 6.2)))
	frag.rotate_speed = 0
	frag.timeout *= 2
	frag.color = Color.STEEL_BLUE
	frag.polygon = poly
	add_sibling(frag)
	
func _is_decayable(poly: PackedVector2Array) -> bool:
	# TODO: this should happen after a cut ends, instead of immediately
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

func _get_fragment():
	# TODO: this will return different fragment shapes depending on material
	return _triangle_fragment(material_chunk_size)	

func _triangle_fragment(size: Vector2):
	var triangle = PackedVector2Array([Vector2(0, -size.y / 2.0), Vector2(size.x / 2.0, size.y / 2.0), Vector2(-size.x / 2.0, size.y / 2.0)])
	return triangle
	
func generate_fragments(n: int, pos: Vector2, travel_vec: Vector2, center: Vector2):
	#return
	for i in n:
		var frag = DebrisFragment.new()
		frag.polygon = _get_fragment()
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
