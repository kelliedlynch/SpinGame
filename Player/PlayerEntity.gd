extends Node2D
class_name PlayerEntity

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
	z_index = RenderLayer.ARENA_ENTITIES

func _process(delta: float) -> void:
	var r = log(pow(destructor.spin_speed, 4)) * delta
	blade_sprite.rotate(r)

func _on_take_damage(dmg: int):
	animation.play("hurt")
