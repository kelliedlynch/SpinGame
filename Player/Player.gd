@tool
extends SGEntity

var size: Vector2 = Vector2(100, 100)

@onready var collision_shape: CollisionShape2D = $PlayerRigidBody/PlayerCollisionShape
@onready var display_shape: Polygon2D = $DrawnPoly

func _init() -> void:
	#$PlayerRigidBody/PlayerCollisionPolygon.polygon = vertices
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().get_root().get_children().has(self):
		$PlayerRigidBody.gravity_scale = 0
		self.position = get_viewport_rect().size / 2
	collision_shape.shape.radius = size.x / 2
	
	#collision_shape.position = -size / 2
	pass # Replace with function body.


func _process(delta: float) -> void:
	#print(collision_shape.global_position)
	display_shape.global_position = collision_shape.global_position
	display_shape.rotate(0.1)
	#display_shape.rotation += .1
	var power = 5000
	if Input.is_action_pressed("ui_left"):
		$PlayerRigidBody.apply_central_force(Vector2(-power, 0))
	if Input.is_action_pressed("ui_right"):
		$PlayerRigidBody.apply_central_force(Vector2(power, 0))
	if Input.is_action_pressed("ui_up"):
		$PlayerRigidBody.apply_central_force(Vector2(0, -power))
	if Input.is_action_pressed("ui_down"):
		$PlayerRigidBody.apply_central_force(Vector2(0, power))
	pass

	
func _input(event: InputEvent) -> void:

	pass
