extends BossAttackBase
class_name JumpAndSmash


var blink: Tween
@onready var landing: Area2D = Area2D.new()

var area_polygon: PackedVector2Array 

func _ready() -> void:
	if area_polygon == null or area_polygon.is_empty():
		call_deferred("_set_default_area_poly")
	landing.z_index = RenderLayer.AREA_TARGET_INDICATORS
	landing.z_as_relative = false
	#arena.add_child(landing)
	tree_exiting.connect(_on_tree_exiting)
	
func _on_tree_exiting():
	#_clear_indicator()
	landing.queue_free()
	if atk_perform != null:
		atk_perform.kill()
	if blink != null:
		blink.kill()
	
func _set_default_area_poly():
	area_polygon = PolygonMath.generate_ellipse_polygon(boss.calculate_size().x * 1.7, boss.calculate_size().y * .7)
	pass
	
func _create_landing_area(origin: Vector2):
	#landing = Area2D.new()
	var boss_size = boss.calculate_size()
	var indicator = CollisionPolygon2D.new()
	indicator.polygon = area_polygon
	landing.add_child(indicator)
	BattleManager.arena.add_child(landing)
	landing.position = BattleManager.arena.to_local(origin + Vector2(0, boss_size.y / 2))
	var visible_landing = Polygon2D.new()
	visible_landing.polygon = area_polygon
	var c = Color.FIREBRICK
	c.a = .2
	visible_landing.modulate = c
	var d = Color.CRIMSON
	d.a = .3

	#visible_landing.color.a = .01
	indicator.add_child(visible_landing)
	blink = create_tween()

	##d.a = .3
	blink.tween_property(visible_landing, "modulate", d, .07)
	blink.tween_property(visible_landing, "modulate", c, .07)
	blink.set_loops(4)

func _clear_indicator():
	BattleManager.arena.remove_child(landing)

func execute_attack():
	var ani = controller.animation_player
	var target = _random_target_area(boss.calculate_size())
	ani.play("OneArmedBanditAnimations/wave_arm")
	atk_perform = create_tween()
	var wave_time = ani.get_animation("OneArmedBanditAnimations/wave_arm").length
	atk_perform.tween_interval(wave_time / 2)
	atk_perform.tween_callback(_create_landing_area.bind(target))
	atk_perform.tween_interval(wave_time / 2)
	atk_perform.tween_callback(boss.set.bind("tangible", false))
	atk_perform.tween_callback(ani.play.bind("OneArmedBanditAnimations/jump_up"))
	var jump_time = ani.get_animation_library("OneArmedBanditAnimations").get_animation("jump_up").length
	var land_time = ani.get_animation_library("OneArmedBanditAnimations").get_animation("jump_landing").length
	atk_perform.tween_interval(jump_time * .5)
	atk_perform.tween_property(boss, "position", target, jump_time * .5 + land_time * .5)
	#var pos = boss.position
	#atk_perform.tween_method(boss.move_to_position, pos, target, jump_time * .5 + land_time * .5)
	atk_perform.tween_callback(ani.play.bind("OneArmedBanditAnimations/jump_landing"))
	atk_perform.tween_interval(land_time * .5)
	atk_perform.tween_callback(_deal_damage)
	atk_perform.tween_callback(boss.set.bind("tangible", true))
	atk_perform.tween_callback(_clear_indicator)
	atk_perform.tween_callback(boss.controller.set.bind("boss_state", BossController.BossState.IDLE))

#func _toggle_collisions():
	#for child in boss.destructibles.get_children():
		#if!(child is PhysicsBody2D): continue
		#if child.collision_layer != CollisionLayer.INTANGIBLE_ENEMY:
			#child.collision_layer = CollisionLayer.INTANGIBLE_ENEMY
		#else:
			#child.collision_layer = CollisionLayer.ENEMY_HITBOX

func _deal_damage():
	for body in landing.get_overlapping_bodies():
		if body is PlayerHitbox and body.owner == Player.entity:
			Player.take_damage(get_damage())
			return
	pass
