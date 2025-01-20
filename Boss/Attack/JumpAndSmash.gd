extends BossAttackBase
class_name JumpAndSmash


var damage = 22
var atk_perform: Tween
var blink: Tween
var landing: Area2D

func _find_landing_spot(boss: BossMonster):
	#var arena = boss.get_parent().get_node("Arena")
	var arena_size = arena.get_node("ArenaBorder").size
	var full_size = boss.calculate_size()
	var walls = arena.get_node("ArenaBorder/LeftWall").shape.size.x
	var x = randi_range(walls + full_size.x / 2, arena_size.x - walls - full_size.x / 2)
	var y = randi_range(walls + full_size.y / 2, arena_size.y - walls - full_size.y / 2)
	return Vector2(x, y)
	
func _create_landing_area(origin: Vector2):
	landing = Area2D.new()
	var boss_size = boss.calculate_size()
	var cap = PolygonMath.generate_ellipse_polygon(boss_size.x * 1.8, boss_size.x * .8)
	var coll = CollisionPolygon2D.new()
	coll.polygon = cap
	landing.add_child(coll)
	landing.position = arena.to_local(origin + Vector2(0, boss_size.y / 2))
	arena.add_child(landing)
	var visible_landing = Polygon2D.new()
	visible_landing.polygon = cap
	var c = Color.DARK_RED
	c.a = .4
	visible_landing.color = c
	coll.add_child(visible_landing)
	blink = create_tween()
	var d = Color(c)
	d.r = 1
	d.a += .2
	blink.tween_property(visible_landing, "modulate", d, .15)
	blink.tween_property(visible_landing, "modulate", c, .15)
	blink.set_loops(4)
	pass

func _clear_landing():
	landing.queue_free()

func execute_attack():
	var ani = boss.controller.animation_player
	var target = _find_landing_spot(boss)
	ani.play("default/wave_arm")
	atk_perform = create_tween()
	var wave_time = ani.get_animation_library("default").get_animation("wave_arm").length
	atk_perform.tween_interval(wave_time / 2)
	atk_perform.tween_callback(_create_landing_area.bind(target))
	atk_perform.tween_interval(wave_time / 2)
	atk_perform.tween_callback(_toggle_collisions)
	atk_perform.tween_callback(ani.play.bind("default/jump_up"))
	var jump_time = ani.get_animation_library("default").get_animation("jump_up").length
	var land_time = ani.get_animation_library("default").get_animation("jump_landing").length
	atk_perform.tween_interval(jump_time * .5)
	atk_perform.tween_property(boss, "position", target, jump_time * .5 + land_time * .5)
	#var pos = boss.position
	#atk_perform.tween_method(boss.move_to_position, pos, target, jump_time * .5 + land_time * .5)
	atk_perform.tween_callback(ani.play.bind("default/jump_landing"))
	atk_perform.tween_interval(land_time * .5)
	atk_perform.tween_callback(_deal_damage)
	atk_perform.tween_callback(_toggle_collisions)
	atk_perform.tween_callback(_clear_landing)
	atk_perform.tween_callback(boss.controller.set.bind("boss_state", BossController.BossState.IDLE))

func _toggle_collisions():
	for child in boss.destructibles.get_children():
		if!(child is PhysicsBody2D): continue
		if child.collision_layer != 16:
			child.collision_layer = 16
		else:
			child.collision_layer = 2

func _deal_damage():
	for body in landing.get_overlapping_bodies():
		if body is PlayerHitbox:
			body.owner.deal_damage(damage)
	pass
