extends Object
class_name PolygonMath

static func generate_circle_polygon(radius) -> Array[Vector2]:
	var min_pts = 18
	var vertices: Array[Vector2] = []
	var pts = max(min_pts, int(360 / radius))
	var interval = 2 * PI / pts
	for i in pts:
		var pt = Vector2(radius * sin(i * interval), radius * cos(i * interval))
		#pt += Vector2(radius, radius)
		vertices.append(pt)
	return vertices
	
static func load_polygon(vertices: Array[Vector2]) -> Array[Vector2]:
	var minpoint = vertices.reduce(min_point, vertices[0])
	if minpoint == Vector2.ZERO: return vertices
	var size = size_of_polygon(vertices)
	var translated: Array[Vector2] = []
	for pt in vertices:
		translated.append(Vector2(pt.x - minpoint.x - size.x / 2, pt.y - minpoint.y - size.y / 2))
	return translated

static func size_of_polygon(vertices: Array[Vector2]) -> Vector2:
	if vertices.size() == 0: return Vector2.ZERO
	var minpoint = vertices.reduce(min_point, vertices[0])
	var maxpoint = vertices.reduce(max_point, vertices[0])
	return Vector2(maxpoint.x - minpoint.x, maxpoint.y - minpoint.y)
	
static func min_point(accum: Vector2, point: Vector2) -> Vector2:
	var minX = accum.x
	var minY = accum.y
	if point.x < minX: minX = point.x
	if point.y < minY: minY = point.y
	return Vector2(minX, minY)

static func max_point(accum: Vector2, point: Vector2) -> Vector2:
	var maxX = accum.x
	var maxY = accum.y
	if point.x > maxX: maxX = point.x
	if point.y > maxY: maxY = point.y
	return Vector2(maxX, maxY)
