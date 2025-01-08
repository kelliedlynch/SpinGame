extends RigidHitbox
class_name Player

#var size: Vector2 = Vector2(100, 100)
#@onready var hitbox: RigidHitbox = $Hitbox
@onready var visible_area: VisibleArea = $VisibleArea
@onready var destructor: Destructor = $Destructor

var max_spin_speed = 10
var spin_speed = 1.25
var spin_accel = 3

func _ready() -> void:
	
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2
	
	var saw = PolygonMath.load_polygon(PolygonVertexData.saw_blade)
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	polygons = [circle]
	visible_area.polygons = [saw]
	destructor.polygons = [circle]
	
	scale_changed.connect(visible_area._on_scale_changed)
	scale_changed.connect(destructor._on_scale_changed)
	super._ready()

	

func _process(delta: float) -> void:
	super._process(delta)
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

#func _physics_process(delta: float) -> void:
	#var power = 1000
	#if Input.is_action_pressed("ui_left"):
		##linear_velocity += Vector2(-power / delta, 0)
		#apply_central_force(Vector2(-power / delta, 0))
	#if Input.is_action_pressed("ui_right"):
		##linear_velocity += Vector2(power / delta, 0)
		#apply_central_force(Vector2(power / delta, 0))
	#if Input.is_action_pressed("ui_up"):
		##linear_velocity += Vector2(0, -power / delta)
		#apply_central_force(Vector2(0, -power / delta))
	#if Input.is_action_pressed("ui_down"):
		##linear_velocity += Vector2(0, power / delta)
		#apply_central_force(Vector2(0, power / delta))
		
#func _input(event: InputEvent) -> void:
	#var power = 1000
	#if event.is_action_pressed("ui_left"):
		##linear_velocity += Vector2(-power, 0)
		#apply_central_force(Vector2(-power, 0))
	#if Input.is_action_pressed("ui_right"):
		#linear_velocity += Vector2(power, 0)
	#if Input.is_action_pressed("ui_up"):
		#linear_velocity += Vector2(0, -power)
	#if Input.is_action_pressed("ui_down"):
		#linear_velocity += Vector2(0, power)
		
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:

	var power = 100
	#state.apply_central_force(Vector2(-power, 0))
	if Input.is_action_pressed("ui_left"):
		state.linear_velocity += Vector2(-power, 0)
		#state.apply_central_force(Vector2(-power, 0))
	if Input.is_action_pressed("ui_right"):
		state.linear_velocity += Vector2(power, 0)
	if Input.is_action_pressed("ui_up"):
		state.linear_velocity += Vector2(0, -power)
	if Input.is_action_pressed("ui_down"):
		state.linear_velocity += Vector2(0, power)


#func _update_render_objects():
	#for child in get_children():
		#if child is CollisionPolygon2D:
			#call_deferred("remove_child", child)
	#for polygon in polygons:
		#var p = CollisionPolygon2D.new()
		#p.polygon = polygon
		#p.scale = entity_scale
		#add_child(p)
