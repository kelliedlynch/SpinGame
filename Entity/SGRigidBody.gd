extends RigidBody2D
class_name SGRigidBody

@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var visible_polygon: Polygon2D = $VisiblePolygon


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	

func load_polygons(hitbox_poly: PackedVector2Array, visible_poly: PackedVector2Array = hitbox_poly):
	hitbox.polygon = hitbox_poly
	visible_polygon.polygon = visible_poly
	#var polysize = PolygonMath.size_of_polygon(visible_poly)
