extends Node2D
class_name Arena

var spawn_point: Vector2
var GRID_COLUMNS = 16

func _ready() -> void:
	spawn_point = get_viewport_rect().size / 2
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
	
	pass
