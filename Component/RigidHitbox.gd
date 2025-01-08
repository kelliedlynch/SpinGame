extends RigidBody2D
class_name RigidHitbox

var _queued_render_change: bool = false

var _polygons: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON]
var polygons: Array[PackedVector2Array]:
	get:
		return _polygons
	set(value):
		_polygons = value
		_queued_render_change = true
		
var _entity_scale: Vector2 = Vector2.ONE
var entity_scale: Vector2:
	get:
		return _entity_scale
	set(value):
		_entity_scale = value
		emit_signal("scale_changed", value)
		
signal scale_changed

func _on_scale_changed(s: Vector2):
	for child in get_children():
		#child.scale = s
		if child is CollisionPolygon2D or child is VisibleArea:
			child.scale = s
		elif child is Destructor:
			for c in child.get_children():
				c.scale = s

static func create_new(poly: Array[PackedVector2Array]) -> RigidHitbox:
	var n = RigidHitbox.new()
	n.polygons = poly
	return n

func _ready() -> void:
	scale_changed.connect(_on_scale_changed)
	_update_render_objects()

func _update_render_objects():
	for child in get_children():
		if child is CollisionPolygon2D:
			call_deferred("remove_child", child)
	for polygon in polygons:
		var p = CollisionPolygon2D.new()
		p.polygon = polygon
		p.scale = entity_scale
		add_child(p)
	#polygons = poly

func _process(_delta: float) -> void:
	var foo = $VisibleArea
	var bar = $VisibleArea.get_children()
	if _queued_render_change == true:
		#call_deferred("_update_render_objects")
		_update_render_objects()
		_queued_render_change = false
	#var power = 10
	#if Input.is_action_pressed("ui_left"):
		#linear_velocity += Vector2(-power, 0)
		##apply_central_force(Vector2(-power, 0))
	#if Input.is_action_pressed("ui_right"):
		#linear_velocity += Vector2(power, 0)
	#if Input.is_action_pressed("ui_up"):
		#linear_velocity += Vector2(0, -power)
	#if Input.is_action_pressed("ui_down"):
		#linear_velocity += Vector2(0, power)
		
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#var power = 10
	#if Input.is_action_pressed("ui_left"):
		##state.linear_velocity += Vector2(-power, 0)
		#apply_central_force(Vector2(-power, 0))
	#if Input.is_action_pressed("ui_right"):
		#state.linear_velocity += Vector2(power, 0)
	#if Input.is_action_pressed("ui_up"):
		#state.linear_velocity += Vector2(0, -power)
	#if Input.is_action_pressed("ui_down"):
		#state.linear_velocity += Vector2(0, power)

func _physics_process(delta: float) -> void:
	var power = 10
	if Input.is_action_pressed("ui_left"):
		linear_velocity += Vector2(-power, 0)
		#apply_central_force(Vector2(-power, 0))
	if Input.is_action_pressed("ui_right"):
		linear_velocity += Vector2(power, 0)
	if Input.is_action_pressed("ui_up"):
		linear_velocity += Vector2(0, -power)
	if Input.is_action_pressed("ui_down"):
		linear_velocity += Vector2(0, power)
