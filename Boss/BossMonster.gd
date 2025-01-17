extends DestructibleEntity
class_name BossMonsterWithPhysics

var timer = 0
var atk_interval = 3

func _process(delta: float) -> void:
	super._process(delta)
	if $AnimationPlayer.is_playing() == false:	
		timer += delta
	if timer > atk_interval:
		timer = 0
		$AnimationPlayer.play("jump_up")
		var tween = create_tween()
		tween.tween_interval(.2)
		tween.tween_property(self, "position", _get_jump_position(), .5)
		tween.set_parallel(true)
		tween.tween_interval(.3)
		tween.tween_callback($AnimationPlayer.play.bind("jump_landing"))
		#$AnimationPlayer.animation_set_next("jump_up", "jump_landing")

func _get_jump_position() -> Vector2:
	var x = randi_range(130, 400)
	var y = randi_range(200, 600)
	if randi() % 2 == 0:
		x = 1600 - x
	return Vector2(x, y)
