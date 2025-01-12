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
# multiplier of polygon size; chunks smaller than this will just vanish
var PRUNE_THRESHOLD = .005
# chunks smaller than this will break off and decay
var chunk_decay_size_threshold = 42

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 20

# TODO: have better cut start/stop detection, so that inertia can factor in. 
const CUT_INERTIA = .1
var material_hardness = 3
var material_resistance = .1
var material_max_cut_speed = 300
var material_linear_damp = 3

var active_destructors = {}

signal fragments_created
signal was_destroyed
signal destructible_area_clipped
signal destructor_destroyed_material

func _init():
	#super._init()
	color = Color.DODGER_BLUE
	#polygons_updated.connect(_on_polygons_updated)

func _ready() -> void:
	was_destroyed.connect(_on_was_destroyed)
	fragments_created.connect(_on_fragments_created)
	#destructible_area.destructor_entered_watch_area.connect(_on_destructor_entered_watch_area)
	destructible_area.destructor_entered_destructible_area.connect(_on_destructor_entered_destructible_area)
	destructible_area.destructor_exited_destructible_area.connect(_on_destructor_exited_destructible_area)
	destructible_area.destructor_exited_watch_area.connect(_on_destructor_exited_watch_area)
	super._ready()

func _on_body_entered_test(node):
	print("body entered destructible area")

	
func _on_was_destroyed():
	queue_free()
	
func update_destructed(polys: Array[PackedVector2Array]):
	var screen_size = get_viewport_rect().size
	var min_side_length = max(screen_size.x, screen_size.y) * .005 / min(entity_scale.x, entity_scale.y)
	var simplified: Array[PackedVector2Array] = []
	for poly in polys:
		simplified.append(PolygonMath.simplify_polygon(poly, min_side_length))
	var pruned: Array[PackedVector2Array] = []
	
	var prune_size = max(screen_size.x, screen_size.y) * PRUNE_THRESHOLD
	for poly in simplified:
		var poly_size = PolygonMath.size_of_polygon(poly) * entity_scale
		if poly_size.x < prune_size and poly_size.y < prune_size:
			continue
		var area = prune_size * prune_size * 2
		if poly_size.x < prune_size * 1.5 or poly_size.y < prune_size * 1.5:
			if poly_size.x * poly_size.y < area:
				continue
		pruned.append(poly)
	if pruned.size() > 1:
		pass
	call_deferred("update_all_polygons", pruned)
	pass

	
func _decay_chunks(polys: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var decayed: Array[PackedVector2Array] = []
	for i in polys.size():
		if _is_decayable(polys[i]) == true:
			var local_poly = []
			for vertex in polys[i]:
				local_poly.append(get_parent().to_local(destructible_area.to_global(vertex)))
			_spawn_debris(local_poly)
			continue
		decayed.append(polys[i])
	return decayed

func _spawn_debris(poly: Array[PackedVector2Array]):
	var frag = DebrisFragment.new()
	frag.velocity = Vector2(randi_range(40, 60) * cos(randf_range(0, 6.2)), randi_range(40, 60) * sin(randf_range(0, 6.2)))
	frag.rotate_speed = 0
	frag.timeout *= 2
	frag.color = Color.STEEL_BLUE
	frag.polygon = poly
	add_sibling(frag)
	
	
func _is_decayable(poly: PackedVector2Array) -> bool:
	var size = PolygonMath.size_of_polygon(poly)
	if size.x < chunk_decay_size_threshold and size.y < chunk_decay_size_threshold:
		return true
	if size.x < chunk_decay_size_threshold * 1.5 or size.y < chunk_decay_size_threshold * 1.5:
		var area = PolygonMath.area_of_polygon(poly)
		return area < pow(chunk_decay_size_threshold, 2)
	return false

func _get_fragment():
	# TODO: this will return different fragment shapes depending on material
	return _triangle_fragment(material_chunk_size)	

func _triangle_fragment(size: Vector2):
	var triangle = PackedVector2Array([Vector2(0, -size.y / 2.0), Vector2(size.x / 2.0, size.y / 2.0), Vector2(-size.x / 2.0, size.y / 2.0)])
	return triangle
	
func _on_fragments_created(n: int, pos: Vector2, travel_vec: Vector2, center: Vector2):
	#return
	for i in n:
		var frag = DebrisFragment.new()
		frag.polygon = _get_fragment()
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
	#node.cut_state = node.CutState.CUTTING
	#node.target = self
	#print("destructor entered destructible area")
	#if node.cut_state == node.CutState.READY and node.last_cut_state != node.CutState.CUTTING:
		#destructor_destroyed_material.connect(node._on_destroyed_material)
		#active_destructors[node] = node
		#node.cut_state = node.CutState.CUTTING
	pass

func _on_destructor_entered_watch_area(node):

	pass
	
func _on_destructor_exited_watch_area(node):
	#hitbox.remove_collision_exception_with(node.get_parent())
	#print("destructor exited watch area")
	#active_destructors.erase(node)
	pass
	
func _on_destructor_exited_destructible_area(node):
	if !(node is Destructor): return
	#node.cut_state = node.CutState.NOT_READY
	#node.target = null
	#print("destructor exited destructible area")
	#if destructor_destroyed_material.is_connected(node._on_destroyed_material):
		#destructor_destroyed_material.disconnect(node._on_destroyed_material)
	#active_destructors.erase(node)
	#if node.cut_state == node.CutState.CUTTING:
		#node.cut_state = node.CutState.NOT_READY
	
	


#func _physics_process(_delta: float) -> void:
	##print(hitbox.sleeping)
	#for destructor in active_destructors:
		##print("player velocity ", destructor.get_parent().linear_velocity)
		#if destructor.cut_state == destructor.CutState.CUTTING:
			#apply_destructor(destructor)
		#elif destructor.last_cut_state == destructor.CutState.CUTTING:
			#if destructor_destroyed_material.is_connected(destructor._on_destroyed_material):
				#destructor_destroyed_material.disconnect(destructor._on_destroyed_material)
			#active_destructors.erase(destructor)
		#print(active_destructors.size())
		#if destructor.get_parent().get_parent().cutting_power() < material_hardness:
			##print("in ", node.get_parent().get_parent().cutting_power())
			#hitbox.remove_collision_exception_with(destructor.get_parent())
			#active_destructors.erase(destructor)
		#hitbox.remove_collision_exception_with(destructor.get_parent())

	#for ex in collision_exceptions:
		#hitbox.add_collision_exception_with(ex)
	#collision_exceptions.clear()
