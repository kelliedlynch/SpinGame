extends Object
class_name PolygonMath

static var DEFAULT_POLYGON: PackedVector2Array = [Vector2(-100, -100), Vector2(100, -100), Vector2(100, 100), Vector2(-100, 100)]

static func generate_circle_polygon(radius) -> PackedVector2Array:
	var min_pts = 18
	var max_pts = 36
	var vertices = PackedVector2Array()
	var pts = min(max(min_pts, int(360 / radius)), max_pts)
	var interval = 2 * PI / pts
	for i in pts:
		var pt = Vector2(radius * sin(i * interval), radius * cos(i * interval))
		#pt += Vector2(radius, radius)
		vertices.append(pt)
	return vertices
	
static func size_of_polygon(vertices: PackedVector2Array) -> Vector2:
	if vertices.size() == 0: return Vector2.ZERO
	var minpoint = min_point(vertices)
	var maxpoint = max_point(vertices)
	return Vector2(maxpoint.x - minpoint.x, maxpoint.y - minpoint.y)
	
static func min_point(vertices: PackedVector2Array) -> Vector2:
	var minX = vertices[0].x
	var minY = vertices[0].y
	for point in vertices:
		if point.x < minX: minX = point.x
		if point.y < minY: minY = point.y
	return Vector2(minX, minY)

static func max_point(vertices: PackedVector2Array) -> Vector2:
	var maxX = vertices[0].x
	var maxY = vertices[0].y
	for point in vertices:
		if point.x > maxX: maxX = point.x
		if point.y > maxY: maxY = point.y
	return Vector2(maxX, maxY)
	
static func simplify_polygon(poly: PackedVector2Array, threshold = 10) -> PackedVector2Array:
	var simplified = PackedVector2Array()
	var prev_pt = poly[-1]
	poly.append(poly[0])
	for i in range(poly.size() - 1):
		#print("distance between points: ", poly[i].distance_to(prev_pt), " ", poly[i].distance_to(poly[i+1]))
		var dist_ba = poly[i].distance_to(prev_pt)
		var dist_bc = poly[i].distance_to(poly[i+1])
		if dist_ba < threshold and  dist_bc < threshold: 
			#print("both distances under threshold, skipping point")
			continue
		elif dist_ba < threshold or dist_bc < threshold:
			simplified.append(poly[i])
			#print("both distances over threshold, keeping point")
			prev_pt = poly[i]
			continue
		var ba = prev_pt - poly[i]
		var bc = poly[i+1] - poly[i]
		var angle = rad_to_deg(abs(ba.angle_to(bc)))
		if (angle > 15 and angle < 165) or (angle > 195 and angle < 345):
			simplified.append(poly[i])
			#print("one value under threshold, keeping point because angle is ", int(angle))
			prev_pt = poly[i]
			continue
		#print("skipping point because angle is ", angle)
	if simplified.size() < 3: return poly
	return simplified

static func rotate_polygon(poly: PackedVector2Array, degrees: int) -> PackedVector2Array:
	var rotated = PackedVector2Array()
	var rads = deg_to_rad(degrees)
	for v in poly:
		var x = v.x * cos(rads) - v.y * sin(rads)
		var y = v.x * sin(rads) + v.y * cos(rads)
		var new_v = Vector2(x, y)
		rotated.append(new_v)
	return rotated

# do we even want this available? I guess it would change the polygon's center point
static func translate_polygon(poly: PackedVector2Array, vector: Vector2) -> PackedVector2Array:
	var translated = PackedVector2Array()
	for v in poly:
		var new_v = v + vector
		translated.append(new_v)
	return translated

# I don't know if this belongs here
#static func polygons_from_children(node: Node2D) -> Array[PackedVector2Array]:
	#var polys: Array[PackedVector2Array] = []
	#for child in node.get_children():
		#if child is CollisionPolygon2D or child is Polygon2D:
			#polys.append(child.polygon)
	#return polys

static func area_of_polygon(poly: PackedVector2Array) -> float:
	var a = 0
	var b = 0
	for i in poly.size() - 1:
		a += poly[i].x * poly[i+1].y
		b += poly[i].y * poly[i+1].x
	return (a - b) / 2
	
static func merge_recursive(polys: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var merged: Array[PackedVector2Array] = [polys[0]]
	for poly in polys:
		var new_merged: Array[PackedVector2Array] = []
		for m in merged:
			new_merged.append_array(Geometry2D.merge_polygons(poly, m))
		merged = new_merged
	if polys.size() == merged.size(): return polys
	return merge_recursive(merged)
