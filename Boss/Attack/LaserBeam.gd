extends BossAttackBase
class_name LaserBeam

var origin: Marker2D
var beam_width: int = 26
var beam_aura_width: int = 1200
var beam_length: int = 0
var beam_aura: Line2D
var beam_line: Line2D
var beam_aura_width_curve: Curve

func _ready() -> void:
	origin = boss.get_node("antenna/laser_beam/beam_origin")
	tree_exiting.connect(_on_tree_exiting)
	min_damage = 20
	max_damage = 30

func execute_attack():
	var ani = boss.animation_player
	#_place_beam()
	ani.play("extend_antenna")
	atk_perform = create_tween()
	atk_perform.tween_interval(1.1)
	atk_perform.tween_callback(_place_beam_aura)

	atk_perform.tween_callback(_tween_curve)
	atk_perform.tween_interval(.6)
	atk_perform.tween_callback(_place_beam)
	atk_perform.tween_callback(_deal_damage)
	atk_perform.tween_interval(.2)
	atk_perform.tween_callback(_remove_beam)
	atk_perform.tween_interval(.55)
	atk_perform.tween_callback(boss.controller.set.bind("boss_state", BossController.BossState.IDLE))
	
func _place_beam():
	beam_line = Line2D.new()
	beam_line.default_color = Color.CRIMSON
	beam_line.default_color.a = .9
	beam_aura.z_index = RenderLayer.ARENA_PARTICLES
	beam_line.add_point(beam_aura.points[0])
	beam_line.add_point(beam_aura.points[1])
	beam_line.width = beam_width
	BattleManager.arena.add_child(beam_line)
	
func _tween_curve():
	var aura_tween = create_tween()
	var old_val = beam_aura.width_curve.get_point_position(1).y
	var new_val = beam_aura.width_curve.get_point_position(0).y
	var callback: Callable = func (x): beam_aura.width_curve.set_point_value(1, x)
	#var b = beam_aura.width_curve
	#beam_aura.width_curve.set_point_value(1, 6)
	aura_tween.tween_method(callback, old_val, new_val, .7)
	#beam_aura.width_curve.set_point_value(1, end_val)
	
func _place_beam_aura():
	var pos = Player.entity.to_global(Player.entity.hitbox.position)
	var target = Vector2(pos)
	var orig_pos = origin.get_parent().to_global(origin.position)
	if beam_length == 0:
		target = orig_pos + orig_pos.direction_to(target) * ProjectSettings.get_setting("display/window/size/viewport_width")
		
	#var curve_ratio = (orig_pos - pos).length_squared() / (orig_pos - target).length_squared()
	var curve_begin_value: float = beam_width / float(beam_aura_width)

	beam_aura = Line2D.new()
	beam_aura.default_color = Color.CRIMSON
	beam_aura.default_color.a = .3
	beam_aura.z_index = RenderLayer.ARENA_PARTICLES
	beam_aura.points = [orig_pos, target]
	beam_aura.width = beam_aura_width
	beam_aura_width_curve = Curve.new()
	beam_aura_width_curve.add_point(Vector2(0, curve_begin_value))
	#if curve_ratio < 1:
		#curve.add_point(Vector2(curve_ratio, 1))
	beam_aura_width_curve.add_point(Vector2(1, 1))
	beam_aura.width_curve = beam_aura_width_curve
	BattleManager.arena.add_child(beam_aura)
	
func _remove_beam():
	beam_aura.queue_free()
	beam_line.queue_free()

func _deal_damage():
	var ray = RayCast2D.new()
	ray.position = beam_line.points[0]
	ray.target_position = beam_line.points[1] - ray.position
	add_child(ray)
	ray.force_raycast_update()
	if ray.get_collider() == Player.entity.hitbox:
		Player.take_damage(get_damage())
	ray.queue_free()
	
func _on_tree_exiting():
	if atk_perform != null:
		atk_perform.kill()
	if beam_aura != null:
		beam_aura.queue_free()
	if beam_line != null:
		beam_line.queue_free()
