extends CollisionPolygon2D
class_name SGCollisionPoly

@onready var base_sprite: Polygon2D = $base_sprite

func find_remote_transform() -> RemoteTransform2D:
	var remote = _check_children_for_remote(owner, self)
	return remote
	
func _check_children_for_remote(node: Node, remote_node: SGCollisionPoly) -> RemoteTransform2D:
	for child in node.get_children():
		if child is RemoteTransform2D and child.get_path_to(self) == child.remote_path:
			return child
		else:
			var remote = _check_children_for_remote(child, remote_node)
			if remote != null:
				return remote
	return null
