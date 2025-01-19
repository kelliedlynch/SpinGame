extends Node

var spawn_point: Vector2

func _ready() -> void:
	spawn_point = get_viewport().size / 2
	var spacing = get_viewport().size.x / 16
	_make_grid_background(spacing)

func _make_grid_background(spacing: float):
	var port = get_viewport().size
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
