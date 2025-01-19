extends SGEntityBase
class_name Player

var hit_points = 100

#var size: Vector2 = Vector2(100, 100)
@onready var hitbox: PlayerHitbox = $Hitbox
#@onready var visible_area: VisibleArea = $VisibleArea
@onready var destructor: Destructor = $Hitbox/Destructor
@onready var blade_sprite: Polygon2D = $Hitbox/saw_blade_coll/saw_blade_vis
@onready var googly_eyes: Node2D = $Hitbox/GooglyEyes


func _ready() -> void:
	super._ready()
	googly_eyes.hitbox = hitbox
	destructor.hitbox = hitbox
	hitbox.destructor = destructor

func _process(delta: float) -> void:

	var r = log(pow(destructor.spin_speed, 4)) * delta
	blade_sprite.rotate(r)
