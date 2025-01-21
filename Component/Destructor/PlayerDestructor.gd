extends Destructor
class_name PlayerDestructor

var hitbox: PlayerHitbox
var max_spin_speed = 10
var min_spin_speed = 10
var spin_speed = 3
var spin_accel = 1.7

func get_power() -> float:
	var speed = spin_speed
	if hitbox.linear_velocity.length() > 500:
		speed += hitbox.linear_velocity.length() / 500
	return speed
	
func _physics_process(delta: float) -> void:
	spin_speed += spin_accel * delta
	spin_speed = clamp(spin_speed, min_spin_speed, max_spin_speed)
	
