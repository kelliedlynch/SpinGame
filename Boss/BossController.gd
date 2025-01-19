extends Node
class_name BossController

var animation_player: AnimationPlayer
var atk_speed = 1
var boss_state = BossState.IDLE
var atk_timer: Tween
var atk_perform: Tween

func _process(_delta: float) -> void:
	if boss_state == BossState.IDLE:
		atk_perform = null
		if atk_timer == null:
			atk_timer = create_tween()
			atk_timer.tween_interval(atk_speed)
			atk_timer.tween_callback(attack)
	elif boss_state == BossState.ATTACKING:
		pass
			
func attack():
	boss_state = BossState.ATTACKING
	atk_timer = null
	var target = _find_landing_spot()
	animation_player.play("default/wave_arm")
	atk_perform = create_tween()
	atk_perform.tween_interval(animation_player.get_animation_library("default").get_animation("wave_arm").length)
	atk_perform.tween_callback(get_parent().hitbox.set.bind("collision_layer", 16))
	atk_perform.tween_callback(animation_player.play.bind("default/jump_up"))
	var jump_time = animation_player.get_animation_library("default").get_animation("jump_up").length
	var land_time = animation_player.get_animation_library("default").get_animation("jump_landing").length
	atk_perform.tween_interval(jump_time * .5)
	atk_perform.tween_property(get_parent(), "position", target, jump_time * .5 + land_time * .5)
	atk_perform.tween_callback(animation_player.play.bind("default/jump_landing"))
	atk_perform.tween_interval(land_time * .5)
	atk_perform.tween_callback(get_parent().hitbox.set.bind("collision_layer", 2))
	atk_perform.tween_callback(set.bind("boss_state", BossState.IDLE))
	#atk_perform.tween_property(self, "boss_state", BossState.IDLE, 0)
	
func _find_landing_spot():
	var arena = get_parent().get_parent().get_node("Arena")
	var arena_size = arena.get_node("ArenaBorder").size
	var full_size = get_parent().calculate_size()
	var walls = arena.get_node("ArenaBorder/LeftWall").shape.size.x
	var x = randi_range(walls + full_size.x / 2, arena_size.x - walls - full_size.x / 2)
	var y = randi_range(walls + full_size.y / 2, arena_size.y - walls - full_size.y / 2)
	return Vector2(x, y)

func _disable_collision(entity):
	for shape in entity.hitbox:
		shape.collision_layer = 5
	pass
		

enum BossState {
	IDLE,
	ATTACKING
}
