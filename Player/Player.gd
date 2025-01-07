extends RigidPolygonEntity
class_name Player

var size: Vector2 = Vector2(100, 100)

@onready var destructor: Area2D = $RigidBody/Destructor
@onready var destructor_polygon: CollisionPolygon2D = $RigidBody/Destructor/DestructPolygon

var max_spin_speed = 10
var spin_speed = 1.75
var spin_accel = 3
var max_speed = 1000

func _ready() -> void:
	super._ready()
	body.lock_rotation = true
	var saw = PolygonMath.load_polygon(PolygonVertexData.saw_blade)
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	body.load_polygons(circle, saw)
	var new_scale = size / polysize
	scale_polygons(new_scale)
	visible_polygon.color = Color.DODGER_BLUE

func _process(delta: float) -> void:
	spin_speed += delta * spin_accel
	spin_speed = clamp(spin_speed, 0, max_spin_speed)
	visible_polygon.rotate(spin_speed * delta)
	# TODO: change this to only affect when cuttin into a material
	body.linear_damp = clamp(body.linear_damp - spin_speed / 10, -1, +1)

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
	body.linear_velocity = body.linear_velocity.limit_length(max_speed)


func scale_polygons(new_scale) -> void:
	super.scale_polygons(new_scale)
	destructor_polygon.scale = new_scale
