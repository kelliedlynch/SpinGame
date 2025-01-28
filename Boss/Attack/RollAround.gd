extends BossAttackBase
class_name RollAround

var target: Vector2
var target_indicator: Line2D = Line2D.new()
var damage_area: Area2D = Area2D.new()
var damage_polygon: PackedVector2Array

func _ready() -> void:
	add_child(target_indicator)
	var body = boss.get_node("Skeleton2D/body_bone")
	body.add_child(damage_area)
	target_indicator.default_color = Color.CRIMSON
	target_indicator.default_color.a = .3
	#process_mode = ProcessMode.PROCESS_MODE_DISABLED
	#super._ready()

func execute_attack():
	var ani = boss.animation_player
	#var target = _random_target_area(boss.calculate_size())
	ani.stop()
	ani.play("curl_up")
	#ani.queue("roll_only")
	atk_perform = create_tween()
	var curl_time = ani.get_animation("curl_up").length
	atk_perform.tween_interval(curl_time)
	
	atk_perform.tween_callback(_pick_target_spot)
	#atk_perform.tween_callback(boss.set.bind("boss_state", BossController.BossState.MOVING))
	#atk_perform.tween_callback(set.bind("process_mode", ProcessMode.PROCESS_MODE_INHERIT))
	atk_perform.tween_callback(_create_damage_area_shapes)
	atk_perform.tween_callback(damage_area.body_entered.connect.bind(_on_damage_area_entered))
	atk_perform.tween_callback(_start_rolling)
	atk_perform.tween_interval(.4)
	atk_perform.tween_callback(_roll_to_position)
	atk_perform.tween_interval(.2)
	atk_perform.tween_callback(_remove_target_indicator)
	
	#atk_perform.tween_property(boss, "position", target, .5)
	
	atk_perform.tween_interval(.4)
	atk_perform.tween_callback(ani.stop)
	atk_perform.tween_callback(ani.play.bind("uncurl"))
	#atk_perform.tween_callback(boss.set.bind("boss_state", BossController.BossState.ATTACKING))
	atk_perform.tween_callback(damage_area.body_entered.disconnect.bind(_on_damage_area_entered))
	atk_perform.tween_callback(_remove_damage_area_shapes)
	#atk_perform.tween_callback(set.bind("process_mode", ProcessMode.PROCESS_MODE_DISABLED))
	atk_perform.tween_interval(curl_time)
	atk_perform.tween_callback(attack_finished.emit)

func _on_damage_area_entered(node):
	if node == Player.entity.hitbox:
		_deal_damage()

func _create_damage_area_shapes():
	var shape = CollisionPolygon2D.new()
	shape.polygon = damage_polygon
	damage_area.add_child(shape)
	
func _remove_damage_area_shapes():
	for child in damage_area.get_children():
		child.queue_free()

func _roll_to_position():
	var tween = create_tween()
	tween.tween_property(boss, "position", target, .6)

func _pick_target_spot():
	target = Player.entity.hitbox.global_position
	#target_indicator = Line2D.new()
	target_indicator.add_point(boss.global_position)
	target_indicator.add_point(target)
	damage_polygon = _get_damage_bolt_area()
	var poly_size = PolygonMath.size_of_polygon(damage_polygon)
	target_indicator.width = (poly_size.x + poly_size.y) / 2
	#target_indicator.queue_redraw()

func _remove_target_indicator():
	target_indicator.clear_points()
	

func _start_rolling():
	if boss.global_position.x > target.x:
		boss.animation_player.play("roll")
	else:
		boss.animation_player.play_backwards("roll")

func _get_damage_bolt_area() -> PackedVector2Array:
	var vertices := PackedVector2Array()
	for bolt in boss.damage_bolts.get_children():
		for point in bolt.points:
			vertices.append(damage_area.to_local(bolt.to_global(point)))
	return Geometry2D.convex_hull(vertices)

func _deal_damage():
	Player.take_damage(get_damage())

func _process(delta):
	pass
