extends Polygon2D
class_name DebrisFragment

var timeout = randf_range(.6, .9)
var velocity = Vector2(300, 300) * Vector2(randf_range(-1, 1), randf_range(-1, 1)) + Vector2(randf_range(-100, 100), randf_range(-100, 100))
var rotate_speed = randf_range(.5, 3)

func _process(delta: float) -> void:
	if timeout <= 0:
		queue_free()
	position += velocity * delta
	rotation += rotate_speed * delta
	timeout -= delta
