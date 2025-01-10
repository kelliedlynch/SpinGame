extends SGEntityBase
class_name DestructibleEntity

#@onready var destructible_area: DestructionArea = $DestructionArea
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

var material_hardness = 10

var active_destructors = {}

var collision_exceptions = []

signal fragments_created
signal was_destroyed
signal destructible_area_clipped

func _init():
	#super._init()
	color = Color.DODGER_BLUE
	#polygons_updated.connect(_on_polygons_updated)

func _ready() -> void:
	polygons_updated.connect(destructible_area._on_polygons_updated)
	super._ready()
	#polygons_updated.connect(destructible_area._on_polygons_updated)
	#destructible_area.update_watch_area()
	#hitbox.position = destructible_area.position
	#destructible_area_clipped.connect(destructible_area.update_slowdown_zone)
	#destructible_area.area_entered.connect(_on_destructible_area_entered)
	#destructible_area.area_exited.connect(_on_destructible_area_exited)
	destructible_area.area_entered.connect(_on_destructor_entered_destructible_area)
	#destructible_area.area_exited.connect(_on_destructor_exited_destructible_area)
	#destructible_area.area_exited.connect(hitbox._on_destructor_exited_area)
	was_destroyed.connect(_on_was_destroyed)
	fragments_created.connect(_on_fragments_created)
	#destructible_area.destructor_entered_watch_area.connect(_on_destructor_entered_watch_area)
	#destructible_area.destructor_entered_destructible_area.connect(_on_destructor_entered_destructible_area)
	destructible_area.destructor_exited_destructible_area.connect(_on_destructor_exited_destructible_area)
	destructible_area.destructor_exited_watch_area.connect(_on_destructor_exited_watch_area)
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
	var any_overlap = false
	var polys_before_clipping = get_polygons(destructible_area)
	for existing_poly in polys_before_clipping:
		for destruct_poly in translated_destructor_polys:

			var overlap = Geometry2D.intersect_polygons(existing_poly, destruct_poly)
			if overlap.is_empty():
				polys_after_destruction.append(existing_poly)
				continue
			any_overlap = true
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
				#print(destructor.get_parent().linear_velocity)
				var center = destructor.get_parent().to_global(destructor.position)
				emit_signal("fragments_created", 1, destructible_area.to_global(overlap_vertices[i]), destructor.get_parent().linear_velocity, center)
			polys_after_destruction.append_array(_simplify_and_prune(clipped_original))
			if polys_after_destruction.size() == 0:
				pass
	if any_overlap == false: return

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

	#update_polygons(destructible_area.slowdown_zone, polys_before_clipping)
	update_polygons(destructible_area, polys_after_decay)
	#emit_signal("destructible_area_clipped", polys_after_decay)
	#call_deferred("update_polygons", destructible_area.slowdown_zone, polys_after_decay)
	destructible_area.update_slowdown_zone(polys_after_decay)
	#call_deferred("update_polygons", destructible_area, polys_after_decay)
	#call_deferred("update_polygons", visible_area, polys_after_decay)
	#call_deferred("update_polygons", hitbox, polys_after_decay)
	update_polygons(visible_area, polys_after_decay)
	update_polygons(hitbox, polys_after_decay)
	


func _simplify_and_prune(poly: Array) -> Array:
	var simplified_and_pruned = []
	for shape in poly:
		var simplified_chunk = PolygonMath.simplify_polygon(shape)
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
	
func _on_fragments_created(n: int, pos: Vector2, travel_vec: Vector2, center: Vector2):
	for i in n:
		var frag = DebrisFragment.new()
		frag.polygon = _get_fragment(Vector2(8, 8))
		frag.color = Color.YELLOW
		frag.position = pos
		var vector_to_tan = pos - center
		var angle_diff = vector_to_tan.angle_to(travel_vec)
		var mult = -1 if angle_diff > 0 else 1
		
		var angle_vec = vector_to_tan.angle()
		var rot = angle_vec + PI/2 * mult
		var out_vec = Vector2.from_angle(rot)
		#var travel_angle = travel_vec.angle()
		#var to_pt_angle = to_pt.angle()
		#var diff = to_pt_angle - travel_angle
		


		var speed = randi_range(160, 200)
		#print(Vector2.from_angle(offset))
		frag.velocity = out_vec * speed
		add_sibling(frag)


func _on_destructor_entered_destructible_area(node):
	if !(node is Destructor): return
	#print("entered destructible area")
	var vel = node.get_parent().get_parent().pre_collision_velocity
	#node.get_parent().apply_central_impulse(vel)
	#var vel = node.get_parent(erial_override
	#var bounce = hitbox.material.bounce
	hitbox.add_collision_exception_with(node.get_parent())
	#hitbox.call_deferred("add_collision_exception_with", node.get_parent())
	#call_deferred("add_exception", node.get_parent())
	
	active_destructors[node] = node
	destructible_area.destructors[node] = node
	pass

func _on_destructor_entered_watch_area(node):
	#destructible_area.destructor_exited_watch_area.connect(_on_destructor_exited_watch_area)
	#hitbox.add_collision_exception_with(node.get_parent())
	#active_destructors[node] = node
	pass
	
func _on_destructor_exited_watch_area(node):
	hitbox.remove_collision_exception_with(node.get_parent())
	pass
	
func _on_destructor_exited_destructible_area(node):
	if !(node is Destructor): return
	#hitbox.remove_collision_exception_with(node.get_parent())
	#print("exited destructible area")
	active_destructors.erase(node)
	
	


func _physics_process(_delta: float) -> void:
	#print(hitbox.sleeping)
	
	for destructor in active_destructors:
		#print("player velocity ", destructor.get_parent().linear_velocity)
		apply_destructor(destructor)
		#if destructor.get_parent().get_parent().cutting_power() < material_hardness:
			##print("in ", node.get_parent().get_parent().cutting_power())
			#hitbox.remove_collision_exception_with(destructor.get_parent())
			#active_destructors.erase(destructor)
		#hitbox.remove_collision_exception_with(destructor.get_parent())
	#for ex in collision_exceptions:
		#hitbox.add_collision_exception_with(ex)
	#collision_exceptions.clear()
