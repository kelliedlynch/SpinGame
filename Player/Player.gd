extends RigidHitbox
class_name Player

#var size: Vector2 = Vector2(100, 100)
#@onready var hitbox: RigidHitbox = $Hitbox
@onready var visible_area: VisibleArea = $VisibleArea
@onready var destructor: Destructor = $Destructor

var max_spin_speed = 10
var spin_speed = 1.25
var spin_accel = 3
var max_speed = 1000

#var velocity = Vector2.ZERO

#var _queued_render_change: bool = false
#
#var _polygons: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON]
#var polygons: Array[PackedVector2Array]:
	#get:
		#return _polygons
	#set(value):
		#_polygons = value
		#_queued_render_change = true

#var _size: Vector2 = Vector2.ZERO
#var size: Vector2:
	#get:
		#return _size
	#set(value):
		#_size = value
		#emit_signal("size_changed", _size, value)
		
#var _entity_scale: Vector2 = Vector2.ONE
#var entity_scale: Vector2:
	#get:
		#return _entity_scale
	#set(value):
		#_entity_scale = value
		#emit_signal("scale_changed", value)
		#
#signal scale_changed

func _ready() -> void:
	
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2
	#scale_changed.connect(_on_scale_changed)
	super._ready()
	var saw = PolygonMath.load_polygon(PolygonVertexData.saw_blade)
	var polysize = PolygonMath.size_of_polygon(saw)
	var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	polygons = [circle]
	visible_area.polygons = [saw]
	destructor.polygons = [circle]
	#_update_render_objects()

#func _on_scale_changed(s: Vector2):
	#for child in get_children():
		#if child is CollisionPolygon2D:
			#child.scale = s
	#destructor.scale = s
	#visible_area.scale = s
	

func _process(delta: float) -> void:
	super._process(delta)
	#if _queued_render_change == true:
		#call_deferred("_update_render_objects")
		#_queued_render_change = false
	spin_speed += delta * spin_accel
	spin_speed = clamp(spin_speed, 0, max_spin_speed)
	var r = spin_speed * delta
	rotate(r)
	print(global_position, linear_velocity)
	#destructor.position = hitbox.position
	#visible_area.position = hitbox.position
	#position += velocity * delta

#func _physics_process(delta: float) -> void:
	#var power = 1
	#if Input.is_action_pressed("ui_left"):
		##linear_velocity += Vector2(-power / delta, 0)
		#apply_central_force(Vector2(-power / delta, 0))
	#if Input.is_action_pressed("ui_right"):
		#linear_velocity += Vector2(power / delta, 0)
	#if Input.is_action_pressed("ui_up"):
		#linear_velocity += Vector2(0, -power / delta)
	#if Input.is_action_pressed("ui_down"):
		#linear_velocity += Vector2(0, power / delta)
		
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#var power = 10
	#if Input.is_action_pressed("ui_left"):
		#state.linear_velocity += Vector2(-power, 0)
		##apply_central_force(Vector2(-power, 0))
	#if Input.is_action_pressed("ui_right"):
		#state.linear_velocity += Vector2(power, 0)
	#if Input.is_action_pressed("ui_up"):
		#state.linear_velocity += Vector2(0, -power)
	#if Input.is_action_pressed("ui_down"):
		#state.linear_velocity += Vector2(0, power)


#func _update_render_objects():
	#for child in get_children():
		#if child is CollisionPolygon2D:
			#call_deferred("remove_child", child)
	#for polygon in polygons:
		#var p = CollisionPolygon2D.new()
		#p.polygon = polygon
		#p.scale = entity_scale
		#add_child(p)
