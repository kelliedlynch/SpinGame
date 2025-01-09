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
var chunk_destroy_size_threshold = 4

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 20

var active_destructors = {}


signal was_destroyed

static func create_new(poly: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON], positions: PackedVector2Array = [Vector2.ZERO]) -> DestructibleEntity:
	var new = preload("res://Entity/DestructibleEntity.tscn").instantiate()
	var p = poly.size()
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
	#destructible_area.queue_free()
	
func _on_was_destroyed():
	queue_free()
	
func apply_destructor(destructor: Destructor):
	var translated_destructor_polys: Array[PackedVector2Array] = []
	for poly in destructor.get_children():
		if !(poly is CollisionPolygon2D): continue
		var new_poly: PackedVector2Array = []
		for pt in poly.polygon:
			var a = destructor.to_global(pt)
			var b = poly.to_global(pt)
			var c = self.to_global(pt)
			var d = destructible_area.to_local(c)
			var e = self.to_local(c)
			var f = visible_area.to_local(c)
			
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
				#for j in overlap[i].size():	
					#overlap_vertices.append(overlap[i][j])
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
			polys_after_destruction.append_array(_simplify_and_prune(clipped_original))
			if polys_after_destruction.size() == 0:
				pass

	var final_polys = polys_after_destruction.size()

	if final_polys == 0:
		emit_signal("was_destroyed")
		return
	
	for i in final_polys:
		#update_polygons(destructible_area, polys_after_destruction)
		call_deferred("update_polygons", destructible_area, polys_after_destruction)
		call_deferred("update_polygons", visible_area, polys_after_destruction)
		call_deferred("update_polygons", hitbox, polys_after_destruction)
		#hitbox.polygons = polys_after_destruction
		#update_polygons(visible_area, polys_after_destruction)

func _simplify_and_prune(poly: Array) -> Array:
	var simplified_and_pruned = []
	for shape in poly:
		var simplified_chunk = PolygonMath.simplify3(shape)
		var simplified_size = PolygonMath.size_of_polygon(simplified_chunk)
		if simplified_size.x < chunk_destroy_size_threshold or simplified_size.y < chunk_destroy_size_threshold:
			continue
		simplified_and_pruned.append(simplified_chunk)
	if simplified_and_pruned.size() == 0:
		pass
	return simplified_and_pruned
	
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
			var fragment_size = PolygonMath.size_of_polygon(chunk_after_clip[j])
			if fragment_size.x < chunk_destroy_size_threshold or fragment_size.y < chunk_destroy_size_threshold:
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
