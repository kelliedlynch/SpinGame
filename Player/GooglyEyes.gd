@tool
extends Node2D

@onready var left_eye: Polygon2D = $left_eye_shape
@onready var right_eye: Polygon2D = $right_eye_shape
@onready var left_pupil: Polygon2D = $left_eye_shape/left_pupil_shape
@onready var right_pupil: Polygon2D = $right_eye_shape/right_pupil_shape

var hitbox: PlayerHitbox

var JITTER: float = .1
var GRAVITY_THRESHOLD: int = 200
var GRAVITY: float = 2

func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	z_index = RenderLayer.ARENA_ENTITIES + 1
	z_as_relative = false
	
func _ready() -> void:
	if Engine.is_editor_hint() == true:
		set_deferred("process_mode", ProcessMode.PROCESS_MODE_INHERIT)

func _process(delta: float) -> void:
	var applied_vel = Vector2.ZERO
	if hitbox != null:
		applied_vel += -hitbox.linear_velocity * delta 
	var p = PolygonMath.size_of_polygon(left_eye.polygon)
	var jitter = max(p.x, p.y) * JITTER
	var x = applied_vel.x + randf_range(-jitter, jitter)
	var y = applied_vel.y + randf_range(-jitter, jitter)
	if hitbox == null or hitbox.linear_velocity.length() < GRAVITY_THRESHOLD:
		y += GRAVITY
	applied_vel = Vector2(x, y)
	var eyes = [left_eye, right_eye]
	var pupils = [left_pupil, right_pupil]
	for i in eyes.size():
		var local_pupil = PackedVector2Array()
		for pt in pupils[i].polygon:
			local_pupil.append(eyes[i].to_local(pupils[i].to_global(pt + applied_vel)))
		var clipped = Geometry2D.clip_polygons(local_pupil, eyes[i].polygon)
		#pupils[i].position += applied_vel
		if clipped.is_empty():
			pupils[i].position += applied_vel
			continue
		for j in local_pupil.size():
			local_pupil[j] -= applied_vel / 2
		var half_clipped = Geometry2D.clip_polygons(local_pupil, eyes[i].polygon)
		if half_clipped.is_empty():
			pupils[i].position += applied_vel / 2
