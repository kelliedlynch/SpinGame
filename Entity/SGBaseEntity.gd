extends Node2D
class_name SGBaseEntity

# Base class for all physics entities.

func _ready() -> void:
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2
