extends SGEntityBase
class_name Player

var size: Vector2 = Vector2(100, 100)

@onready var destructor: Area2D = $Destructor

var max_spin_speed = 10
var spin_speed = 1.25
var spin_accel = 3
var max_speed = 1000

func _ready() -> void:
	super._ready()
	var saw = PolygonMath.load_polygon(PolygonVertexData.saw_blade)
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	load_polygons([circle], [saw], [circle])
	visible_area.color = Color.DODGER_BLUE
	
func load_polygons(poly: Array[PackedVector2Array], vis: Array[PackedVector2Array] = poly, destruct: Array[PackedVector2Array] = poly):
	super.load_polygons(poly, vis)
	destructor.polygons = destruct

func _process(delta: float) -> void:
	spin_speed += delta * spin_accel
	spin_speed = clamp(spin_speed, 0, max_spin_speed)
	var r = spin_speed * delta
	rotate(r)

func _physics_process(delta: float) -> void:
	var power = 30
	
	if Input.is_action_pressed("ui_left"):
		$RigidBody.apply_central_force(Vector2(-power / delta, 0))
	if Input.is_action_pressed("ui_right"):
		$RigidBody.apply_central_force(Vector2(power / delta, 0))
	if Input.is_action_pressed("ui_up"):
		$RigidBody.apply_central_force(Vector2(0, -power / delta))
	if Input.is_action_pressed("ui_down"):
		$RigidBody.apply_central_force(Vector2(0, power / delta))
	#body.linear_velocity = body.linear_velocity.limit_length(max_speed)


#func scale_polygons(new_scale) -> void:
	#super.scale_polygons(new_scale)
	#destructor_polygon.scale = new_scale
