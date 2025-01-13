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
	
static func simplify_polygon(poly: PackedVector2Array, min_side_length, angle_threshold = .05) -> PackedVector2Array:
	var size = size_of_polygon(poly)
	var simplified = PackedVector2Array()
	var prev_pt = poly[-1]
	poly.append(poly[0])
	for i in range(poly.size() - 1):
		var dist_ba = poly[i].distance_to(prev_pt)
		var dist_bc = poly[i].distance_to(poly[i+1])
		if dist_ba < min_side_length and  dist_bc < min_side_length: 
			continue
		elif dist_bc < min_side_length:
			simplified.append(poly[i])
			prev_pt = poly[i]
			continue
		var ba = prev_pt - poly[i]
		var bc = poly[i+1] - poly[i]
		#var angle = rad_to_deg(abs(ba.angle_to(bc)))
		#var at = (360 * angle_threshold)
		#if (angle > at and angle < 180 - at) or (angle > 180 + at and angle < 360 - at):
			#simplified.append(poly[i])
			#prev_pt = poly[i]
			#continue	
		simplified.append(poly[i])
		prev_pt = poly[i]
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

static func area_of_polygon(poly: PackedVector2Array) -> float:
	var a = 0
	var b = 0
	for i in poly.size() - 1:
		a += poly[i].x * poly[i+1].y
		b += poly[i].y * poly[i+1].x
	a += poly[-1].x * poly[0].y
	b += poly[-1].y * poly[0].x
	return (a - b) / 2
	
static func merge_recursive(polys: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var orig_size = polys.size()
	if orig_size == 1: return polys
	var merged: Array[PackedVector2Array] = []

	var i = 0
	while i < orig_size - 1:
		var this_merge = Geometry2D.merge_polygons(polys[i], polys[i+1])
		var holes_removed: Array[PackedVector2Array] = []
		for poly in this_merge:
			if Geometry2D.is_polygon_clockwise(poly) == true:
				#i += 2
				continue
			holes_removed.append(poly)
		merged.append_array(holes_removed)
		i += 2
	if orig_size % 2 == 1:
		merged.append(polys[-1])

	var size_after = merged.size()
	var matched = true
	if size_after <= 1:
		return merged

	if orig_size == size_after:
		for j in size_after:
			if merged[j] == polys[j]:
				continue
			matched = false
			break
	else:
		matched = false
	if matched == true:
		return polys
	
	return merge_recursive(merged)
		
static func generate_capsule_shape(capsule_length, r) -> PackedVector2Array:
	var polys: Array[PackedVector2Array] = [PackedVector2Array(), PackedVector2Array(), PackedVector2Array()]
	var circle = generate_circle_polygon(r)
	if capsule_length <= r * 2 + 10: return circle
	for pt in circle:
		polys[0].append(Vector2(pt.x - capsule_length / 2 + r, pt.y))
		polys[2].append(Vector2(pt.x + capsule_length / 2 - r, pt.y))
	var rect: PackedVector2Array = [Vector2(-(capsule_length / 2 - r), -r),\
				Vector2(capsule_length / 2 - r, -r),\
				Vector2(capsule_length / 2 - r, r),\
				Vector2(-(capsule_length / 2 - r), r)]
	polys[1] = rect
	var merged = merge_recursive(polys)[0]
	return merged
