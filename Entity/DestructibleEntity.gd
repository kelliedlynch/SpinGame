extends SGEntityBase
class_name DestructibleEntity

@onready var destruction_area: DestructionArea = $DestructionArea
#@onready var destruction_polys: Array[PackedVector2Array] = PolygonMath.polygons_from_children($DestructionArea)


var clip_queue: Array[PackedVector2Array] = []
var queued_clip: PackedVector2Array = []
var clip_timer = 3
var clip_timer_elapsed = 0

# TODO: these should probably not be an absolute size; should probably calculate based on rendered size
#		because polygons can be any size and are scaled when rendered
var material_chunk_size = Vector2(20, 20)
var chunk_destroy_size_threshold = 10

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 20


signal was_destroyed

static func new(poly: Array[PackedVector2Array] = [], positions: PackedVector2Array = [Vector2.ZERO]) -> DestructibleNonPhysics:
	var new = preload("res://Entity/DestructibleEntity.tscn").instantiate()
	var p = poly.size()
	if p > 0:
		# remove dummy children in scene
		for child in new.destruction_area.get_children().filter(func (x): return x is CollisionPolygon2D):
			new.destruction_area.remove_child(child)
		for child in new.hitbox_polys_area.get_children().filter(func (x): return x is CollisionPolygon2D):
			new.hitbox_polys_area.remove_child(child)
		for child in new.display_node.get_children().filter(func (x): return x is Polygon2D):
			new.display_node.remove_child(child)
	for i in p:
		var d_poly = CollisionPolygon2D.new()
		d_poly.polygon = poly[i]
		d_poly.position = positions[i]
		new.destruction_area.add_child(d_poly)
		var h_poly = CollisionPolygon2D.new()
		h_poly.polygon = poly[i]
		h_poly.position = positions[i]
		new.hitbox_area.add_child(h_poly)
		var v_poly = Polygon2D.new()
		v_poly.polygon = poly[i]
		v_poly.position = positions[i]
		new.visible_node.add_child(v_poly)
	return new
		

func _ready() -> void:
	super._ready()
	hitbox_area.area_entered.connect(_on_hitbox_area_entered)
	hitbox_area.area_exited.connect(_on_hitbox_area_exited)
	destruction_area.area_entered.connect(_on_destruction_area_entered)
	destruction_area.area_exited.connect(_on_destruction_area_exited)
	was_destroyed.connect(_on_was_destroyed)
	
func _on_was_destroyed():
	queue_free()
	
func apply_destructor(destructor: Destructor):
	var destructor_polys_relative_to_destruction_area = []
	for poly in destructor.destruct_polygon.polygon:
		destructor_polys_relative_to_destruction_area.append(destruction_area.to_local((destructor.to_global(poly))))
	
	var polys_after_destruction: Array[PackedVector2Array] = []
	for existing_poly in destruction_polys:
		for destruct_poly in destructor_polys_relative_to_destruction_area:
			var overlap = Geometry2D.intersect_polygons(existing_poly, destruct_poly)
			if overlap.is_empty(): continue

			var fragment_quantity = min(overlap.size(), material_chunk_quantity)

			var clipped_original = [existing_poly]
			var fragment = _get_fragment(material_chunk_size)
			for i in fragment_quantity:
				var rotated = PolygonMath.rotate_polygon(fragment, randi_range(0, 360))
				var remaining_chunks_of_original_after_clipping = _clip_and_get_chunks(clipped_original, rotated)
				clipped_original = remaining_chunks_of_original_after_clipping
			polys_after_destruction.append_array(_simplify_and_prune(clipped_original))
		
	var final_polys = polys_after_destruction.size()

	if final_polys == 0:
		emit_signal("was_destroyed")
		return
	
	for i in final_polys:
		destruction_polys = polys_after_destruction.map(func (x): 
			var p = CollisionPolygon2D.new()
			p.polygon = x
			return p )
		hitbox_polys = destruction_polys
		visible_polys = polys_after_destruction.map(func (x): 
			var p = Polygon2D.new()
			p.polygon = x
			return p )

func _clip_queued(subject: CollisionPolygon2D, clip: PackedVector2Array):
	subject.set_deferred("polygon", clip)
	print("clipping")

func _simplify_and_prune(poly: Array) -> Array:
	var simplified_and_pruned = []
	for shape in poly:
		var simplified_chunk = PolygonMath.simplify3(shape)
		var simplified_size = PolygonMath.size_of_polygon(simplified_chunk)
		if simplified_size.x < chunk_destroy_size_threshold or simplified_size.y < chunk_destroy_size_threshold:
			continue
		simplified_and_pruned.append(simplified_chunk)
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
	return chunks_after_clipping

func _get_fragment(size: Vector2):
	# TODO: this will return different fragment shapes depending on material
	return _triangle_fragment(size)	

func _triangle_fragment(size: Vector2):
	var triangle = PackedVector2Array([Vector2(0, -size.y / 2.0), Vector2(size.x / 2.0, size.y / 2.0), Vector2(-size.x / 2.0, size.y / 2.0)])
	return triangle


func _on_destruction_area_entered(node):
	if !(node is Destructor): return
	
func _on_destruction_area_exited(node):
	if !(node is Destructor): return

func _on_hitbox_area_entered(_node):
	pass
	
func _on_hitbox_area_exited(_node):
	pass
			
func _process(_delta: float) -> void:
	pass
