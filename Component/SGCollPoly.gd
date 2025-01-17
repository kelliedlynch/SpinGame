extends CollisionPolygon2D
class_name SGCollPoly

@onready var visible_polygon: Polygon2D = get_children()[0]
#@onready var remote_transform: RemoteTransform2D = 

func _ready() -> void:
	item_rect_changed.connect(_on_rect_changed)
	
func _on_rect_changed() -> void:
	print("rect change")

func find_remote_transform() -> RemoteTransform2D:
	var remote = _check_children_for_remote(get_parent().get_parent(), self)
	return remote		
	
func _check_children_for_remote(node: Node, remote_node: SGCollPoly) -> RemoteTransform2D:
	for child in node.get_children():
		if child is RemoteTransform2D and child.get_path_to(self) == child.remote_path:
			return child
		else:
			var remote = _check_children_for_remote(child, remote_node)
			if remote != null:
				return remote
	return null
