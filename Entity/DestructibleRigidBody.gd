extends SGRigidBody
class_name DestructibleRigidBody

@onready var destructible_area: DestructionArea = $DestructionArea
@onready var destructible_polygon: CollisionPolygon2D = $DestructionArea/DestructionPolygon


func load_polygons(hitbox_poly: PackedVector2Array, visible_poly: PackedVector2Array = hitbox_poly, destruct_poly: PackedVector2Array = hitbox_poly):
	super.load_polygons(hitbox_poly, visible_poly)
	#if hitbox_poly == destruct_poly:
		#destruct_poly = Geometry2D.offset_polygon(destruct_poly, 50)[0]
	destructible_polygon.polygon = destruct_poly
