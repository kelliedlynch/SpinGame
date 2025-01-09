extends CharacterBody2D
class_name CharacterHitbox

#var _queued_render_change: bool = false
#
#var _polygons: Array[PackedVector2Array] = [PolygonMath.DEFAULT_POLYGON]
#var polygons: Array[PackedVector2Array]:
	#get:
		#return _polygons
	#set(value):
		#_polygons = value
		#_queued_render_change = true
#
#static func create_new(poly: Array[PackedVector2Array]) -> CharacterHitbox:
	#var n = CharacterHitbox.new()
	#n.polygons = poly
	#return n
#
#func _ready() -> void:
	#_update_render_objects()
#
#func _update_render_objects():
	#for child in get_children():
		#if child is CollisionPolygon2D:
			#call_deferred("remove_child", child)
	#for polygon in polygons:
		#var p = CollisionPolygon2D.new()
		#p.polygon = polygon
		#p.scale = get_parent().scale
		#add_child(p)
#
#func _process(_delta: float) -> void:
	#if _queued_render_change == true:
		#call_deferred("_update_render_objects")
		#_queued_render_change = false
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
