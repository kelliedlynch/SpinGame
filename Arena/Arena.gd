extends Node2D
class_name Arena

@onready var bounds: ArenaBorder = $ArenaBorder
var spawn_point: Vector2
var GRID_COLUMNS = 16
var size: Vector2
var active_area: Rect2

func _ready() -> void:
	z_index = RenderLayer.ARENA_BACKGROUND
	if Engine.is_editor_hint():
		var x = ProjectSettings.get_setting("display/window/size/viewport_width")
		var y = ProjectSettings.get_setting("display/window/size/viewport_height")
		size = Vector2(x, y)
	else:
		size = get_viewport_rect().size
	bounds.wall_thickness = int(size.x / 50)
	active_area = Rect2(bounds.wall_thickness, bounds.wall_thickness, int(size.x) - bounds.wall_thickness * 2, int(size.y) - bounds.wall_thickness * 2)
	bounds.size = size
	bounds.make_walls()
	spawn_point = size / 2
	_make_grid_background()

func _make_grid_background():
	var spacing = get_viewport_rect().size.x / GRID_COLUMNS
	for child in $Grid.get_children():
		child.queue_free()
	var port = get_viewport_rect().size
	var h = port.x / spacing
	var v = port.y / spacing
	var line_color = Color.DEEP_SKY_BLUE
	line_color.a = .5
	for i in h:
		var line = Line2D.new()
		line.points = [Vector2(i * spacing + spacing / 2, 0), Vector2(i * spacing + spacing / 2, port.y)]
		line.width = 3
		line.default_color = line_color
		$Grid.add_child(line)
	for i in v:
		var line = Line2D.new()
		line.points = [Vector2(0, i * spacing + spacing / 2), Vector2(port.x, i * spacing + spacing / 2)]
		line.width = 3
		line.default_color = line_color
		$Grid.add_child(line)
