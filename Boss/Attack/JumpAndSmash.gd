extends Node
class_name JumpAndSmash

static func _find_landing_spot(boss: BossMonsterWithPhysics):
	var arena = boss.get_parent().get_node("Arena")
	var arena_size = arena.get_node("ArenaBorder").size
	var full_size = boss.calculate_size()
	var walls = arena.get_node("ArenaBorder/LeftWall").shape.size.x
	var x = randi_range(walls + full_size.x / 2, arena_size.x - walls - full_size.x / 2)
	var y = randi_range(walls + full_size.y / 2, arena_size.y - walls - full_size.y / 2)
	return Vector2(x, y)

static func execute_attack(boss: BossMonsterWithPhysics):
	var ani = boss.controller.animation_player
	var target = _find_landing_spot(boss)
	ani.play("default/wave_arm")
	var atk_perform = boss.create_tween()
	atk_perform.tween_interval(ani.get_animation_library("default").get_animation("wave_arm").length)
	atk_perform.tween_callback(boss.hitbox.set.bind("collision_layer", 16))
	atk_perform.tween_callback(ani.play.bind("default/jump_up"))
	var jump_time = ani.get_animation_library("default").get_animation("jump_up").length
	var land_time = ani.get_animation_library("default").get_animation("jump_landing").length
	atk_perform.tween_interval(jump_time * .5)
	atk_perform.tween_property(boss, "position", target, jump_time * .5 + land_time * .5)
	atk_perform.tween_callback(ani.play.bind("default/jump_landing"))
	atk_perform.tween_interval(land_time * .5)
	atk_perform.tween_callback(boss.hitbox.set.bind("collision_layer", 2))
	atk_perform.tween_callback(boss.controller.set.bind("boss_state", BossController.BossState.IDLE))
