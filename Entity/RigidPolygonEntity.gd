extends SGBaseEntity
class_name RigidPolygonEntity

@onready var body: SGRigidBody = $RigidBody
@onready var hitbox: CollisionPolygon2D = $RigidBody/Hitbox
@onready var visible_polygon: Polygon2D = $RigidBody/VisiblePolygon

func _ready() -> void:
	super._ready()
	body.contact_monitor = true
	body.max_contacts_reported = 5

func scale_polygons(new_scale):
	body.hitbox.scale = new_scale
	body.visible_polygon.scale = new_scale
