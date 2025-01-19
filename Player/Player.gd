extends Node2D
class_name Player

var hit_points = 100

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $Hitbox
@onready var destructor: Destructor = $Hitbox/Destructor
@onready var blade_sprite: Polygon2D = $Hitbox/saw_blade_coll/saw_blade_vis
@onready var googly_eyes: Node2D = $Hitbox/GooglyEyes
@onready var animation: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	googly_eyes.hitbox = hitbox
	destructor.hitbox = hitbox
	hitbox.destructor = destructor

func _process(delta: float) -> void:
	var r = log(pow(destructor.spin_speed, 4)) * delta
	blade_sprite.rotate(r)

func deal_damage(dmg: int) -> void:
	hit_points -= dmg
	animation.play("hurt")
	if hit_points <= 0:
		queue_free()
