extends SGEntityBase
class_name DestructibleEntity

#@onready var destructible_area: DestructionArea = $DestructionArea
#@onready var destruction_polys: Array[PackedVector2Array] = PolygonMath.polygons_from_children($DestructionArea)
@onready var destructible_area = $DestructibleArea
@onready var visible_area = $VisibleArea
@onready var hitbox = $DestructibleHitbox

# TODO: these should probably not be an absolute size; should probably calculate based on rendered size
#		because polygons can be any size and are scaled when rendered
var material_chunk_size = Vector2(16, 16)
# multiplier based on screen size; min length of side when simplifying polygon
var SIMPLIFY_THRESHOLD = .005
# multiplier based on screen size; chunks smaller than this will just vanish
var PRUNE_THRESHOLD = .005
# chunks smaller than this will break off and decay
var DECAY_THRESHOLD = .025

# this is the maximum number of chunks that can break off when a destructor hits
var material_chunk_quantity = 20

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

func _on_was_destroyed():
	queue_free()
	
func update_destructed(polys: Array[PackedVector2Array]):
	var screen_size = get_viewport_rect().size
	var simplified: Array[PackedVector2Array] = []
	var min_side_length = max(screen_size.x, screen_size.y) * SIMPLIFY_THRESHOLD
	for poly in polys:
		simplified.append(PolygonMath.simplify_polygon(poly, min_side_length))
	var pruned: Array[PackedVector2Array] = []
	
	var prune_size = max(screen_size.x, screen_size.y) * PRUNE_THRESHOLD
	for poly in simplified:
		var poly_size = PolygonMath.size_of_polygon(poly)
		if poly_size.x < prune_size and poly_size.y < prune_size:
			continue
		var area = prune_size * prune_size * 2
		if poly_size.x < prune_size * 1.5 or poly_size.y < prune_size * 1.5:
			if poly_size.x * poly_size.y < area:
				continue
		pruned.append(poly)
	var after_decay = _decay_chunks(pruned)
	
	call_deferred("update_all_polygons", after_decay)
	
	

	
func _decay_chunks(polys: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var decayed: Array[PackedVector2Array] = []
	for i in polys.size():
		if _is_decayable(polys[i]) == true:
			var local_poly = PackedVector2Array()
			for vertex in polys[i]:
				local_poly.append(get_parent().to_local(destructible_area.to_global(vertex)))
			_spawn_debris(local_poly)
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
