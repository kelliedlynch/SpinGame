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
	
# TODO: rework all these polymath functions to use packed arrays
static func load_polygon(vertices: Array[Vector2]) -> PackedVector2Array:
	var minpoint = vertices.reduce(min_point, vertices[0])
	if minpoint == Vector2.ZERO: return vertices
	var size = size_of_polygon(vertices)
	var translated: PackedVector2Array = []
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
	
static func simplify_polygon(poly: PackedVector2Array, threshold = 3) -> PackedVector2Array:
	var size = poly.size()
	if  size <= 4: return poly
	var simplified = PackedVector2Array()
	var first = poly[0]
	var last = poly[-1]
	var max_distance = 0
	var max_index = 0
	for i in range(1, size):
		var pt = Geometry2D.get_closest_point_to_segment(poly[i], first, last)
		var dist = pt.distance_to(poly[i])
		if dist > max_distance:
			max_distance = dist
			max_index = i

	if max_distance >= threshold:
		var poly1 = poly.slice(0, max_index + 1)
		var poly2 = poly.slice(max_index)
		poly2.append(poly[0])
		#var simplified1 = poly1
		if poly1.size() > 3:
			poly1 = simplify_polygon(poly1, threshold)
		if poly2.size() > 3:
			poly2 = simplify_polygon(poly2, threshold)
		simplified.append_array(poly1)
		simplified.append_array(poly2.slice(1, -1))
		return simplified
	#simplified.push_back(first)
	simplified.append(last)

	return simplified

static func simplify2(poly: PackedVector2Array, threshold = 3) -> PackedVector2Array:
	if poly.size() <= 3: return poly
	var simp_front = PackedVector2Array()
	simp_front.append(poly[0])
	var simp_back = PackedVector2Array()
	
	var front = 0
	var back = poly.size() - 1
	
	if poly[0].distance_to(poly[-1]) > threshold:
		simp_back.append(poly[-1])
		pass
	else:
		simp_back.append(poly[-2])
		back -= 1

	var look_front = front + 1
	var look_back = back - 1
	# back or look_back?
	while look_front < back:
		if front + 1 > back - 1:
			print("looking has overlapped")
			# looking forward and back has overlapped
			pass
		if poly[front].distance_to(poly[look_front]) > threshold:
			simp_front.append(poly[look_front])
			front = look_front
			look_front = front + 1
			#look_front += 1
		elif poly[look_front].distance_to(poly[look_front + 1]) > threshold:
			simp_front.append(poly[look_front])
			front = look_front
			look_front = front + 1
		else:
			look_front += 1
		
		if front > look_back: break
		if poly[back].distance_to(poly[look_back]) > threshold:
			simp_back.append(poly[look_back])
			back = look_back
			look_back = back - 1
		elif poly[look_back].distance_to(poly[look_back - 1]) > threshold:
			simp_back.append(poly[look_back])
			back = look_back
			look_back = back - 1
		else:
			look_back -= 1
	
	simp_back.reverse()
	simp_front.append_array(simp_back)
	
	print("checking polygon with look_front ", look_front, " and look_back ", look_back)
	for i in simp_front.size() - 1:
		if simp_front[i].distance_to(simp_front[i+1]) <= threshold:
			print("side below threshold remains in polygon")
	
	return simp_front

static func simplify3(poly: PackedVector2Array, threshold = 10) -> PackedVector2Array:
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
		var new_v = Vector2(v.x * sin(rads), v.y * cos(rads))
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
static func polygons_from_children(node: Node2D) -> Array[PackedVector2Array]:
	var polys: Array[PackedVector2Array] = []
	for child in node.get_children():
		if child is CollisionPolygon2D or child is Polygon2D:
			polys.append(child.polygon)
	return polys
