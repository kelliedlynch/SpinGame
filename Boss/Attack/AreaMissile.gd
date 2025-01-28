extends BossAttackBase
class_name AreaMissile

var missile: Sprite2D
var target_position: Vector2
var area_size: Vector2 = Vector2(900, 500)
var target_indicator: TargetIndicator
var explosion: CPUParticles2D
@onready var damage_area: Area2D = Area2D.new()

func _ready():
	add_child(damage_area)

func execute_attack():
	var ani = boss.animation_player
	ani.play("fire_missile")
	target_position = _random_target_area(area_size)
	_draw_target_indicator()
	atk_perform = create_tween()
	atk_perform.tween_interval(1.25)
	atk_perform.tween_callback(_place_missile)
	#atk_perform.tween_interval()
	atk_perform.tween_callback(_move_missile)

func _add_explosion():
	explosion = load("res://ExplosionParticles.tscn").instantiate()
	explosion.position = target_position
	add_child(explosion)
	explosion.emitting = true
	explosion.finished.connect(explosion.queue_free)

func _place_missile():
	#var pos = boss.heart_location.global_position
	#target_position = pos
	missile = Sprite2D.new()
	missile.texture = load("res://Graphics/bomb.png")
	missile.position = boss.heart.global_position
	missile.z_index = RenderLayer.AREA_TARGET_INDICATORS
	add_child(missile)

func _move_missile():
	var missile_tween = create_tween()
	var off_screen = missile.global_position - Vector2(0, boss.get_viewport_rect().size.y)
	missile_tween.tween_property(missile, "global_position", off_screen, .5)
	missile_tween.tween_interval(.3)
	missile_tween.tween_callback(missile.rotate.bind(PI))
	missile_tween.tween_callback(missile.set.bind("global_position", Vector2(target_position.x, off_screen.y)))
	missile_tween.tween_property(missile, "global_position", target_position, 1)
	missile_tween.tween_callback(_remove_target_indicator)
	missile_tween.tween_callback(missile.queue_free)
	missile_tween.tween_callback(_add_explosion)
	missile_tween.tween_callback(_deal_damage)
	missile_tween.tween_interval(.5)
	missile_tween.tween_callback(boss.controller.set.bind("boss_state", BossController.BossState.IDLE))

func _deal_damage():
	for body in damage_area.get_overlapping_bodies():
		if body is PlayerHitbox and body.owner == Player.entity:
			Player.take_damage(get_damage())
			break
	for child in damage_area.get_children():
		child.queue_free()
	
func _draw_target_indicator():
	target_indicator = TargetIndicator.new()
	target_indicator.width = area_size.x
	target_indicator.height = area_size.y
	target_indicator.z_index = RenderLayer.AREA_TARGET_INDICATORS
	target_indicator.global_position = target_position
	add_child(target_indicator)
	var tween = create_tween()
	tween.tween_property(target_indicator, "modulate:a", .7, .1)
	tween.tween_property(target_indicator, "modulate:a", .4, .1)
	tween.set_loops(4)
	tween.finished.connect(target_indicator.set.bind("modulate:a", target_indicator.color.a))
	var coll = CollisionPolygon2D.new()
	coll.polygon = target_indicator.polygon
	coll.global_position = target_position
	damage_area.add_child(coll)
	#atk_perform.finished.connect(coll.queue_free)
	
	
func _remove_target_indicator():
	if target_indicator != null:
		target_indicator.queue_free()
