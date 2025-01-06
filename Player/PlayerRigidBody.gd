extends SGRigidBody
class_name PlayerRigidBody

@onready var destructor_polygon: CollisionPolygon2D = self.get_node("Destructor/DestructPolygon")

func load_polygons(hitbox_poly: PackedVector2Array, visible_poly: PackedVector2Array = hitbox_poly, destruct_poly: PackedVector2Array = hitbox_poly):
	super.load_polygons(hitbox_poly, visible_poly)
	if hitbox_poly == destruct_poly:
		destruct_poly = Geometry2D.offset_polygon(destruct_poly, 50)[0]
	destructor_polygon.polygon = destruct_poly
