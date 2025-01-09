extends SGEntityBase
class_name DestructibleEntity

#@onready var destruction_area: DestructionArea = $DestructionArea
#@onready var destruction_polys: Array[PackedVector2Array] = PolygonMath.polygons_from_children($DestructionArea)
@onready var destructible_area = $DestructibleArea
@onready var visible_area = $VisibleArea
@onready var hitbox = $StaticHitbox

var clip_queue: Array[PackedVector2Array] = []
var queued_clip: PackedVector2Array = []
var clip_timer = 3
var clip_timer_elapsed = 0

# TODO: these should probably not be an absolute size; should probably calculate based on rendered size
#		because polygons can be any size and are scaled when rendered
var material_chunk_size = Vector2(20, 20)
# chunks smaller than this will just vanish
var chunk_pruning_size_threshold = 16 
# chunks smaller than this will break off and decay
var chunk_decay_size_threshold = 42

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 20

var active_destructors = {}

signal fragments_created
signal was_destroyed

func _init():
	color = Color.DODGER_BLUE

static func create_new(poly: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON], positions: PackedVector2Array = [Vector2.ZERO]) -> DestructibleEntity:
	var new = preload("res://Entity/DestructibleEntity.tscn").instantiate()
	var p = poly.size()
	new.color = Color.DODGER_BLUE
	new.update_all_polygons(poly)
	return new
		

func _ready() -> void:
	super._ready()
	#hitbox.position = destructible_area.position
	
	destructible_area.area_entered.connect(_on_destruction_area_entered)
	destructible_area.area_exited.connect(_on_destruction_area_exited)
	#destructible_area.area_entered.connect(hitbox._on_destructor_entered_area)
	#destructible_area.area_exited.connect(hitbox._on_destructor_exited_area)
	was_destroyed.connect(_on_was_destroyed)
	fragments_created.connect(_on_fragments_created)
	#destructible_area.queue_free()
	
func _on_was_destroyed():
	queue_free()
	
func apply_destructor(destructor: Destructor):
	var translated_destructor_polys: Array[PackedVector2Array] = []
	for poly in destructor.get_children():
		if !(poly is CollisionPolygon2D): continue
		var new_poly: PackedVector2Array = []
		for pt in poly.polygon:
			new_poly.append(destructible_area.to_local((poly.to_global(pt))))
		translated_destructor_polys.append(new_poly)
	
	var polys_after_destruction: Array[PackedVector2Array] = []
	for existing_poly in get_polygons(destructible_area):
		for destruct_poly in translated_destructor_polys:

			var overlap = Geometry2D.intersect_polygons(existing_poly, destruct_poly)
			if overlap.is_empty():
				polys_after_destruction.append(existing_poly)
				continue
			var overlap_vertices: PackedVector2Array = []
			for i in overlap.size():
				overlap_vertices.append_array(overlap[i])
			var fragment_quantity = min(overlap_vertices.size(), material_chunk_quantity)
			var clipped_original: Array[PackedVector2Array] = []
			clipped_original.append(existing_poly)

			var fragment = _get_fragment(material_chunk_size)
			for i in fragment_quantity:
				var rotated = PolygonMath.rotate_polygon(fragment, randi_range(0, 360))
				for j in rotated.size():
					rotated[j] += overlap_vertices[i]
				var remaining_chunks_of_original_after_clipping = _clip_and_get_chunks(clipped_original, rotated)
				clipped_original = remaining_chunks_of_original_after_clipping
				if clipped_original.size() == 0:
					pass
				emit_signal("fragments_created", 1, destructible_area.to_global(overlap_vertices[i]))
			polys_after_destruction.append_array(_simplify_and_prune(clipped_original))
			if polys_after_destruction.size() == 0:
				pass
			

	var final_polys = polys_after_destruction.size()

	if final_polys == 0:
		emit_signal("was_destroyed")
		return
	
	var polys_after_decay: Array[PackedVector2Array] = []
	for i in final_polys:
		if _is_decayable(polys_after_destruction[i]) == true:
			var local_poly = []
			for vertex in polys_after_destruction[i]:
				local_poly.append(get_parent().to_local(destructible_area.to_global(vertex)))
			
			var frag = DebrisFragment.new()
			frag.velocity = Vector2(randi_range(40, 60) * cos(randf_range(0, 6.2)), randi_range(40, 60) * sin(randf_range(0, 6.2)))
			frag.rotate_speed = 0
			frag.timeout *= 2
			frag.color = Color.STEEL_BLUE
			frag.polygon = local_poly
			add_sibling(frag)
			
			
			
			
			continue
			
			
		polys_after_decay.append(polys_after_destruction[i])
		
		
	if polys_after_decay.size() == 0:
		emit_signal("was_destroyed")
		return		
	
	
	
	#update_polygons(destructible_area, polys_after_destruction)
	update_polygons(destructible_area, polys_after_decay)
	update_polygons(visible_area, polys_after_decay)
	update_polygons(hitbox, polys_after_decay)
	#call_deferred("update_polygons", destructible_area, polys_after_decay)
	#call_deferred("update_polygons", visible_area, polys_after_decay)
	#call_deferred("update_polygons", hitbox, polys_after_decay)
	#hitbox.polygons = polys_after_destruction
	#update_polygons(visible_area, polys_after_destruction)

func _simplify_and_prune(poly: Array) -> Array:
	var simplified_and_pruned = []
	for shape in poly:
		var simplified_chunk = PolygonMath.simplify3(shape)
		var simplified_size = PolygonMath.size_of_polygon(simplified_chunk)
		if _is_prunable(simplified_chunk) == true:
			continue
		simplified_and_pruned.append(simplified_chunk)
	if simplified_and_pruned.size() == 0:
		pass
	return simplified_and_pruned
	
func _is_decayable(poly: PackedVector2Array) -> bool:
	var size = PolygonMath.size_of_polygon(poly)
	if size.x < chunk_decay_size_threshold and size.y < chunk_decay_size_threshold:
		return true
	if size.x < chunk_decay_size_threshold * 1.5 or size.y < chunk_decay_size_threshold * 1.5:
		var area = PolygonMath.area_of_polygon(poly)
		return area < pow(chunk_decay_size_threshold, 2)
	return false

func _is_prunable(poly: PackedVector2Array) -> bool:
	var size = PolygonMath.size_of_polygon(poly)
	if size.x < chunk_pruning_size_threshold and size.y < chunk_pruning_size_threshold:
		return true
	if size.x < chunk_pruning_size_threshold * 1.5 or size.y < chunk_pruning_size_threshold * 1.5:
		var area = PolygonMath.area_of_polygon(poly)
		return area < pow(chunk_pruning_size_threshold, 2)
	return false
	
func _clip_and_get_chunks(poly: Array[PackedVector2Array], clipper: PackedVector2Array) -> Array[PackedVector2Array]:
	var chunks_after_clipping: Array[PackedVector2Array] = []
		# for each polygon in current clipped shape
	for i in poly.size():
		# clip each polygon by fragment polygon
		var chunk_after_clip = Geometry2D.clip_polygons(poly[i], clipper)
		var fragments_of_chunk = chunk_after_clip.size()
		if fragments_of_chunk == 0: continue
		for j in fragments_of_chunk:
			# if this fragment is actually a hole in the original, disregard (all fragments should come out of an edge)
			if Geometry2D.is_polygon_clockwise(chunk_after_clip[j]) == true:
				continue
			# if this fragment is below the size threshold, disregard (no tiny specks remaining)
			if _is_prunable(chunk_after_clip[j]) == true:
				continue
			chunks_after_clipping.append(chunk_after_clip[j])
	if chunks_after_clipping.size() == 0:
		pass
	return chunks_after_clipping

func _get_fragment(size: Vector2):
	# TODO: this will return different fragment shapes depending on material
	return _triangle_fragment(size)	

func _triangle_fragment(size: Vector2):
	var triangle = PackedVector2Array([Vector2(0, -size.y / 2.0), Vector2(size.x / 2.0, size.y / 2.0), Vector2(-size.x / 2.0, size.y / 2.0)])
	return triangle
	
func _on_fragments_created(n: int, pos: Vector2):
	for i in n:
		var frag = DebrisFragment.new()
		frag.polygon = _get_fragment(Vector2(8, 8))
		frag.color = Color.YELLOW
		frag.position = pos
		add_sibling(frag)

func _on_destruction_area_entered(node):
	if !(node is Destructor): return
	hitbox.add_collision_exception_with(node.get_parent())
	active_destructors[node] = node
	
	
func _on_destruction_area_exited(node):
	if !(node is Destructor): return
	#hitbox.remove_collision_exception_with(node.get_parent())
	active_destructors.erase(node)

func _on_hitbox_area_entered(_node):
	pass
	
func _on_hitbox_area_exited(_node):
	pass
			
func _process(_delta: float) -> void:
	for destructor in active_destructors:
		apply_destructor(destructor)
