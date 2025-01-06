extends RigidBody2D
class_name SGRigidBody

@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var visible_polygon: Polygon2D = $VisiblePolygon
@onready var destructor: Area2D = $DestructArea
@onready var destructor_polygon: CollisionPolygon2D = $DestructArea/DestructPolygon

func load_polygons(hitbox_poly: PackedVector2Array, visible_poly: PackedVector2Array = hitbox_poly, destruct_poly: PackedVector2Array = hitbox_poly):
	hitbox.polygon = hitbox_poly
	
	visible_polygon.polygon = visible_poly
	var polysize = PolygonMath.size_of_polygon(visible_poly)
	#visible_polygon.offset = -polysize / 2
	#hitbox = -polysize / 2
	#hitbox.translate(-polysize / 2)
	if destructor_polygon != null:
		destructor_polygon.polygon = destruct_poly
		#destructor_polygon.translate(-polysize / 2)
