extends RigidPolygonEntity
class_name DestructibleEntity

@onready var destruction_area: DestructionArea = $RigidBody/DestructionArea
@onready var destruction_polygon: CollisionPolygon2D = $RigidBody/DestructionArea/DestructionPolygon

var destroying = false

var clip_next_tick: PackedVector2Array = []
var clip_queue: Array[PackedVector2Array] = []
var queued_clip: PackedVector2Array = []
var clip_timer = 3
var clip_timer_elapsed = 0

var chunk_destroy_size_threshold = 10

var active_destructors = []

signal was_destroyed

func _ready() -> void:
	super._ready()
	body.body_entered.connect(_on_body_entered)
	body.body_exited.connect(_on_body_exited)
	destruction_area.area_entered.connect(_on_area_entered)
	destruction_area.area_exited.connect(_on_area_exited)
	was_destroyed.connect(_on_was_destroyed)
	
func _on_was_destroyed():
	queue_free()
	
func apply_destructor(destructor: Destructor):
	var destructor_relative_to_this: PackedVector2Array = []
	for pt in destructor.destruct_polygon.polygon:
		destructor_relative_to_this.append(body.to_local((destructor.destruct_polygon.to_global(pt))))
	var overlap = Geometry2D.intersect_polygons(hitbox.polygon, destructor_relative_to_this)
	if overlap.is_empty(): return

	var destructor_frag_size = PolygonMath.size_of_polygon(destructor_relative_to_this) * Vector2(destructor.clipper_size, destructor.clipper_size)
	var all_overlap_points = []
	for i in overlap:
		all_overlap_points.append_array(i)

	var fragment_quantity = min(all_overlap_points.size(), destructor.clipper_quantity)

	var clipped_original = [hitbox.polygon]
	var fragment = triangle_fragment(destructor_frag_size.x)
	for i in fragment_quantity:
		var this_fragment = []
		for j in fragment.size():
			var rads = deg_to_rad(randi() % 360)
			var rotated = Vector2(fragment[j].x * sin(rads), fragment[j].y * cos(rads))
			this_fragment.append(rotated + all_overlap_points[i])
			
		var remaining_chunks_of_original_after_clipping = _clip_and_get_chunks(clipped_original, this_fragment)

		clipped_original = remaining_chunks_of_original_after_clipping
	var simplified_and_pruned = _simplify_and_prune(clipped_original)
		
	var final_polys = simplified_and_pruned.size()

	if final_polys == 0:
		emit_signal("was_destroyed")

	if final_polys == 1:
		visible_polygon.polygon = simplified_and_pruned[0]
		hitbox.polygon = simplified_and_pruned[0]
		destruction_polygon.polygon = simplified_and_pruned[0]
		#var c = func(): destruction_polygon.polygon = clipped_original[0]
		#call_deferred("_clip_queued", destruction_polygon, simplified_and_pruned[0])
		#queued_clip = simplified_and_pruned[0]
		#clip_queue.append(simplified_and_pruned[0])

	if final_polys > 1:
		for i in final_polys:
			# TODO: change this later; also look at what flags are needed if _init is overridden
			var new_node = duplicate()
			get_parent().add_child(new_node)
			new_node.visible_polygon.polygon = simplified_and_pruned[i]
			new_node.hitbox.polygon = simplified_and_pruned[i]
			new_node.destruction_polygon.polygon = simplified_and_pruned[i]
			#call_deferred("_clip_queued", destruction_polygon, simplified_and_pruned[i])
		call_deferred("queue_free")
		#queue_free()
	
	# TODO: make a better system for slowing down spin speed
	destructor.get_parent().get_parent().spin_speed -=.1

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
	
func _clip_and_get_chunks(poly: Array, this_fragment: PackedVector2Array) -> Array:
	var remaining_chunks_of_original_after_clipping = []
		# for each polygon in current clipped shape
	for k in poly.size():
		# clip each polygon by fragment polygon
		var this_chunk_of_original_after_clipping = Geometry2D.clip_polygons(poly[k], this_fragment)
		var new_fragments_of_chunk = this_chunk_of_original_after_clipping.size()
		if new_fragments_of_chunk == 0: continue
		for q in new_fragments_of_chunk:
			if Geometry2D.is_polygon_clockwise(this_chunk_of_original_after_clipping[q]) == true:
				#print("clockwise")
				continue
			var size_of_this_fragment_of_chunk = PolygonMath.size_of_polygon(this_chunk_of_original_after_clipping[q])
			if size_of_this_fragment_of_chunk.x < chunk_destroy_size_threshold or size_of_this_fragment_of_chunk.y < chunk_destroy_size_threshold:
				continue
			#var simplified_chunk = PolygonMath.simplify_polygon(this_chunk_of_original_after_clipping[q])
			remaining_chunks_of_original_after_clipping.append(this_chunk_of_original_after_clipping[q])
	return remaining_chunks_of_original_after_clipping

func triangle_fragment(size: int):
	var triangle = PackedVector2Array([Vector2(0, -size / 2.0), Vector2(size / 2.0, size / 2.0), Vector2(-size / 2.0, size / 2.0)])
	return triangle


func _on_area_entered(node):
	if !(node is Destructor): return
	var index = active_destructors.find(node)
	if index == -1: active_destructors.append(node)
	#destroying = true
	#var c = Callable(self, "apply_destructor")
	#c.call_deferred(node)
	#apply_destructor(node)
	
func _on_area_exited(node):
	if !(node is Destructor): return
	var index = active_destructors.find(node)
	if index >= 0: active_destructors.remove_at(index)

func _on_body_entered(_node):
	pass
	
func _on_body_exited(_node):
	pass
			
func _process(_delta: float) -> void:
	for d in active_destructors:
		#apply_destructor(d)
		call_deferred("apply_destructor", d)
	#if destroying == true:
		#call_deferred("apply_destructor", )
	#if clip_queue.size() > 0:
		#if clip_timer_elapsed > clip_timer:
			#destruction_polygon.polygon = clip_queue.pop_front()
		#clip_timer_elapsed += 1
	#elif clip_timer_elapsed > 0:
		#clip_timer_elapsed = 0
