extends RigidPolygonEntity
class_name Player

var size: Vector2 = Vector2(100, 100)

@onready var destructor: Area2D = $RigidBody/Destructor
@onready var destructor_polygon: CollisionPolygon2D = $RigidBody/Destructor/DestructPolygon

var spin_speed = 0.75

func _ready() -> void:
	super._ready()
	body.lock_rotation = true
	var saw = PolygonMath.load_polygon(PolygonVertexData.saw_blade)
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	body.load_polygons(circle, saw)
	var new_scale = size / polysize
	scale_polygons(new_scale)

func _process(delta: float) -> void:
	visible_polygon.rotate(spin_speed * delta)

func _physics_process(delta: float) -> void:
	var power = 1000
	
	if Input.is_action_pressed("ui_left"):
		$RigidBody.apply_central_force(Vector2(-power, 0))
	if Input.is_action_pressed("ui_right"):
		$RigidBody.apply_central_force(Vector2(power, 0))
	if Input.is_action_pressed("ui_up"):
		$RigidBody.apply_central_force(Vector2(0, -power))
	if Input.is_action_pressed("ui_down"):
		$RigidBody.apply_central_force(Vector2(0, power))

func scale_polygons(new_scale) -> void:
	super.scale_polygons(new_scale)
	destructor_polygon.scale = new_scale
