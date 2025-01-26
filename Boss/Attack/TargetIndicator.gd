extends Node2D
class_name TargetIndicator

var width: float
var height: float
var polygon: PackedVector2Array
var line_width: float = 8
var color: Color = Color(1, .1, .1, .6)

func _ready() -> void:
	polygon = PolygonMath.generate_ellipse_polygon(width * .9, height * .9)
	polygon.append(polygon[0])

func _draw() -> void:
	draw_polyline(polygon, color, line_width)
	draw_line(Vector2(0, -height / 2), Vector2(0, height / 2), color, line_width)
	draw_line(Vector2(-width / 2, 0), Vector2(width / 2, 0), color, line_width)
	
