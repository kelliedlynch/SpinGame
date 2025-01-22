@tool
extends Line2D
class_name LightningBolt

#var end_point: Vector2
#var begin_point: Vector2



var flicker: float = .08
var flicker_time_remaining: float = 0
var min_segment_mult: float = .012
var max_segment_mult: float = .04
var min_segment_length: float = 0
var max_segment_length: float = 0
var divergence: float = .8

@onready var prev_bolt = $prev_bolt
@onready var bolt_glow = $bolt_glow
@onready var prev_bolt_glow = $prev_bolt/prev_bolt_glow

func _ready() -> void:
	var length = 0
	if Engine.is_editor_hint():
		var x = ProjectSettings.get_setting("display/window/size/viewport_width")
		var y = ProjectSettings.get_setting("display/window/size/viewport_height")
		length = min(x, y)
	else:
		var s = get_viewport_rect().size
		length = min(s.x, s.y)
	min_segment_length = length * min_segment_mult
	max_segment_length = length * max_segment_mult
	pass
		

#func _notification(what: int) -> void:
	#if what is 

	
func _generate_points() -> PackedVector2Array:
	if points.size() < 2: return points
	var vec = points[-1] - points[0]
	var length = vec.length()
	var line_limited_min_seg_length = length * min_segment_mult
	var line_limited_max_seg_length = length * max_segment_mult
	var min_seg = (line_limited_min_seg_length + min_segment_length) / 2
	var max_seg = (line_limited_max_seg_length + max_segment_length) / 2
	#var div = length * divergence
	var total_length = 0
	var vertices = PackedVector2Array()
	vertices.append(points[0])
	while total_length < length:
		var distance = total_length + randf_range(min_seg, max_seg)
		if distance > length: break
		total_length = distance
		var new_point = points[0].move_toward(points[-1], total_length)
		var offset_point = new_point.move_toward(vec.orthogonal(), randf_range(-(min_seg + max_seg) / 2 * divergence, (min_seg + max_seg) / 2 * divergence))
		vertices.append(offset_point)
		
	vertices.append(points[-1])
	return vertices

func _process(delta: float) -> void:
	#if points[0] != begin_point or points[-1] != end_point:
		##points = _generate_points()
		#set("begin_point", points[0])
		#set("end_point", points[1])
	#else:
	if flicker_time_remaining < 0:
		prev_bolt.points = points
		prev_bolt_glow.points = bolt_glow.points
		set_deferred("points", call("_generate_points"))
		bolt_glow.set_deferred("points", call("get", "points"))
		flicker_time_remaining = flicker
	else:
		flicker_time_remaining -= delta
