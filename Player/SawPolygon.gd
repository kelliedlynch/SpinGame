extends Polygon2D


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	var vertices = load_polygon(base_vertices)
	polygon = vertices
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO: Store polygon data elsewhere
var base_vertices: Array[Vector2] = [Vector2(174,202), Vector2(150,178), Vector2(141,144), Vector2(123,153), Vector2(108,185), Vector2(105,219), Vector2(120,251), Vector2(123,286), Vector2(114,321), Vector2(106,355), Vector2(83,373), Vector2(54,356), Vector2(27,345), Vector2(34,380), Vector2(43,414), Vector2(70,436), Vector2(99,457), Vector2(116,487), Vector2(129,520), Vector2(142,553), Vector2(112,568), Vector2(77,567), Vector2(80,586), Vector2(106,610), Vector2(137,624), Vector2(172,620), Vector2(206,627), Vector2(236,646), Vector2(266,665), Vector2(276,692), Vector2(251,715), Vector2(233,737), Vector2(268,741), Vector2(303,743), Vector2(332,724), Vector2(361,703), Vector2(395,696), Vector2(430,694), Vector2(466,692), Vector2(471,725), Vector2(459,758), Vector2(478,761), Vector2(509,744), Vector2(532,719), Vector2(539,684), Vector2(557,654), Vector2(584,631), Vector2(611,608), Vector2(639,607), Vector2(653,638), Vector2(669,662), Vector2(683,630), Vector2(696,597), Vector2(687,564), Vector2(677,530), Vector2(680,496), Vector2(689,461), Vector2(698,427), Vector2(731,432), Vector2(759,454), Vector2(768,436), Vector2(761,402), Vector2(744,372), Vector2(713,355), Vector2(690,329), Vector2(677,296), Vector2(664,263), Vector2(671,235), Vector2(705,232), Vector2(732,225), Vector2(706,201), Vector2(679,179), Vector2(644,177), Vector2(609,176), Vector2(578,162), Vector2(548,143), Vector2(518,124), Vector2(534,94), Vector2(563,74), Vector2(549,60), Vector2(513,56), Vector2(480,64), Vector2(454,88), Vector2(422,102), Vector2(386,104), Vector2(351,106), Vector2(327,91), Vector2(334,57), Vector2(336,29), Vector2(305,46), Vector2(276,65), Vector2(263,98), Vector2(252,131), Vector2(229,157), Vector2(202,179)]

func load_polygon(vertices: Array[Vector2]) -> Array[Vector2]:
	var minpoint = vertices.reduce(min_point, vertices[0])
	if minpoint == Vector2.ZERO: return vertices
		
	var translated: Array[Vector2] = []
	for pt in vertices:
		translated.append(Vector2(pt.x - minpoint.x, pt.y - minpoint.y))
	return translated

func size_of_polygon(vertices: Array[Vector2]) -> Vector2:
	var minpoint = vertices.reduce(min_point, vertices[0])
	var maxpoint = vertices.reduce(max_point, vertices[0])
	return Vector2(maxpoint.x - minpoint.x, maxpoint.y - minpoint.y)
	
func min_point(accum: Vector2, point: Vector2) -> Vector2:
	var minX = accum.x
	var minY = accum.y
	if point.x < minX: minX = point.x
	if point.y < minY: minY = point.y
	return Vector2(minX, minY)

func max_point(accum: Vector2, point: Vector2) -> Vector2:
	var maxX = accum.x
	var maxY = accum.y
	if point.x > maxX: maxX = point.x
	if point.y > maxY: maxY = point.y
	return Vector2(maxX, maxY)
