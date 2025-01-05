@tool
extends RigidPolygonEntity

var size: Vector2 = Vector2(100, 100)
@onready var visible_polygon: SawPolygon = $VisibleObject/Polygon

func _ready() -> void:
	super._ready()
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2
	hitbox.polygon = generate_circle_polygon(size.x / 2)
	var polysize = visible_polygon.size_of_polygon(visible_polygon.polygon)
	var scale = size / polysize
	visible_node.scale = scale
	visible_polygon.offset = -polysize / 2


func _process(delta: float) -> void:
	$VisibleObject.rotate(0.1)
	var power = 5000
	if Input.is_action_pressed("ui_left"):
		$RigidBody.apply_central_force(Vector2(-power, 0))
	if Input.is_action_pressed("ui_right"):
		$RigidBody.apply_central_force(Vector2(power, 0))
	if Input.is_action_pressed("ui_up"):
		$RigidBody.apply_central_force(Vector2(0, -power))
	if Input.is_action_pressed("ui_down"):
		$RigidBody.apply_central_force(Vector2(0, power))
	super._process(delta)

	
func _on_body_entered(node):
	print("ping", node)
