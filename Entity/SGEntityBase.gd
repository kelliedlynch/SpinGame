extends Node2D
class_name SGEntityBase

# Base class for all game entities.
# An entity has a hitbox and a visible component
# Entity polygons are centered around point (0, 0)

func _ready() -> void:
	if get_tree().get_root().get_children().has(self):
		self.position = get_viewport_rect().size / 2

#func load_polygons(hitbox: Array[PackedVector2Array], vis: Array[PackedVector2Array] = hitbox)-> void:
	#hitbox_area.polygons = hitbox
	#visible_area.polygons = vis

func _process(delta: float) -> void:
	if $Hitbox == null: return
	var g = global_position
	var hg = $Hitbox.global_position
	var l = position
	var hl = $Hitbox.position
	global_position = $Hitbox.global_position
	for child in $Hitbox.get_children():
		child.scale = scale
