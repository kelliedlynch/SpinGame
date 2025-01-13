extends SGEntityBase
class_name Player

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $RigidHitbox
@onready var visible_area: VisibleArea = $RigidHitbox/VisibleArea
@onready var destructor: Destructor = $RigidHitbox/Destructor


func _ready() -> void:
	var saw = PolygonVertexData.saw_blade
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	update_polygons(hitbox, [circle])
	update_polygons(visible_area, [saw])
	var cap = PolygonMath.generate_capsule_shape(polysize.x, polysize.x / 2)
	update_polygons(destructor, [cap])
	
	super._ready()

func _process(delta: float) -> void:

	var r = destructor.spin_speed * delta / 4
	visible_area.rotate(r)
