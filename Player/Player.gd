extends SGEntityBase
class_name Player

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $RigidHitbox
@onready var visible_area: VisibleArea = $RigidHitbox/VisibleArea
@onready var destructor: Destructor = $RigidHitbox/Destructor

var max_spin_speed = 10
var min_spin_speed = .1
var spin_speed = 1
var spin_accel = .7

#signal needs_push
var pre_collision_velocity = Vector2.ZERO

#func _init() -> void:
	#var saw = PolygonVertexData.saw_blade
	#var polysize = PolygonMath.size_of_polygon(saw)
	#var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	#update_polygons(hitbox, [circle])
	#update_polygons(visible_area, [saw])
	#update_polygons(destructor, [circle])

func _ready() -> void:
	var saw = PolygonVertexData.saw_blade
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	update_polygons(hitbox, [circle])
	update_polygons(visible_area, [saw])
	update_polygons(destructor, [circle])
	super._ready()

func _process(delta: float) -> void:
	if destructor.cut_state != destructor.CutState.CUTTING:
		spin_speed += delta * spin_accel
		spin_speed = clamp(spin_speed, min_spin_speed, max_spin_speed)
	var r = spin_speed * delta
	visible_area.rotate(r)
