extends SGEntityBase
class_name Player

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $RigidHitbox
@onready var visible_area: VisibleArea = $RigidHitbox/VisibleArea
@onready var destructor: Destructor = $RigidHitbox/Destructor

var max_spin_speed = 10
var spin_speed = 1.25
var spin_accel = 3

#signal needs_push
var linear_velocity = Vector2.ZERO

func _ready() -> void:
	#
	#if get_tree().get_root().get_children().has(self):
		#self.position = get_viewport_rect().size / 2
	
	var saw = PolygonMath.load_polygon(PolygonVertexData.saw_blade)
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	#var circle2 = Geometry2D.offset_polygon(circle, 100)
	update_polygons(hitbox, [circle])
	update_polygons(visible_area, [saw])
	update_polygons(destructor, [circle])
	#hitbox.body_entered.connect(_on_body_entered)
	#hitbox.body_shape_entered.connect(_on_body_shape_entered)
	#needs_push.connect(_on_needs_push)
	#scale_changed.connect(visible_area._on_scale_changed)
	#scale_changed.connect(destructor._on_scale_changed)
	super._ready()

func _on_body_entered(node):
	print("incoming velocity", hitbox.linear_velocity)
	if node is AnimatableBody2D: 
		hitbox.queued_push = hitbox.linear_velocity
	
func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int):
	print("body shape entered")
	pass

func cutting_power() -> float:
	return linear_velocity.length() / 10 * destructor.power * sqrt(spin_speed)

func _process(delta: float) -> void:
	#super._process(delta)
	#if _queued_render_change == true:
		#call_deferred("_update_render_objects")
		#_queued_render_change = false
	spin_speed += delta * spin_accel
	spin_speed = clamp(spin_speed, 0, max_spin_speed)
	var r = spin_speed * delta
	visible_area.rotate(r)
	#print(global_position, linear_velocity)
	var power = 1000
	#if Input.is_action_pressed("ui_left"):
		##linear_velocity += Vector2(-power, 0)
		#apply_central_force(Vector2(-power, 0))
