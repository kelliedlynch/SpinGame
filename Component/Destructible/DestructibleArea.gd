extends Area2D
class_name DestructibleArea

var active_watch_area: Area2D = Area2D.new()
var watch_radius := 20

#var slowdown_zone := Area2D.new()

signal destructor_entered_watch_area
signal destructor_exited_watch_area
signal destructor_entered_destructible_area
signal destructor_exited_destructible_area

var destructors = {}

#func _init() -> void:
	#get_parent().polygons_updated.connect(_on_polygons_updated)
	#pass
var queued = {}

func _ready() -> void:
	monitoring = true
	monitorable = false
	linear_damp = 100
	linear_damp_space_override = SPACE_OVERRIDE_COMBINE
	#slowdown_zone.linear_damp = 100
	#slowdown_zone.linear_damp_space_override = SPACE_OVERRIDE_COMBINE
	
	add_child(active_watch_area)
	#add_child(slowdown_zone)


	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	get_parent().polygons_updated.connect(_on_polygons_updated)
	active_watch_area.monitoring = true
	active_watch_area.monitorable = false
	active_watch_area.area_entered.connect(_on_watch_area_entered)
	active_watch_area.area_exited.connect(_on_watch_area_exited)
	
func _on_area_entered(node):
	if !(node is Destructor): return
	#print("DestructibleArea destructible area entered")
	#destructors[node] = node
	#linear_damp = 100
	emit_signal("destructor_entered_destructible_area", node)

func _on_area_exited(node):
	if !(node is Destructor): return
	#print("DestructibleArea destructible area exited")
	emit_signal("destructor_exited_destructible_area", node)

		
func _on_watch_area_entered(node):
	if !(node is Destructor): return


func _on_watch_area_exited(node):
	if !(node is Destructor): return
	emit_signal("destructor_exited_watch_area", node)
	#print("DestructibleArea watch area exited")

	
func _on_polygons_updated(node):
	if node == self:
		#call_deferred("update_watch_area")
		#update_slowdown_zone()
		update_watch_area()

#func update_slowdown_zone(polys):
	#var prior_children = slowdown_zone.get_children()
	#for poly in polys:
		#var new_shape = CollisionPolygon2D.new()
		#new_shape.polygon = poly
		#slowdown_zone.add_child(new_shape)
	#await get_tree().physics_frame
	#for child in prior_children:
		#if child != null:
			#child.queue_free()
	#pass
		
func update_watch_area():
	#return
	#if active_watch_area == null: return
	var watch_polygons: Array[PackedVector2Array] = []
	for child in get_children():
		if child is CollisionPolygon2D:
			watch_polygons.append(child.polygon)
			#var slow = CollisionPolygon2D.new()
			#slow.polygon = child.polygon
			#slowdown_zone.add_child(slow)
			#child.call_deferred("queue_free")
	if watch_polygons.is_empty() == true: return

	var expanded: Array[PackedVector2Array] = []
	for poly in watch_polygons:
		expanded.append_array(Geometry2D.offset_polygon(poly, watch_radius,Geometry2D.JOIN_SQUARE))
	if expanded.is_empty() == true: return
	var prior_children = active_watch_area.get_children()
	for poly in expanded:
		var p = CollisionPolygon2D.new()
		p.polygon = poly
		#print("adding new polygon")
		active_watch_area.add_child(p)
	#
	for child in prior_children:
		if child is CollisionPolygon2D:
			child.queue_free()
			#print("call remove child deferred")
			#active_watch_area.call_deferred("remove_child", child)
			#print("queue remove child")
			#queued[child] = child
			
	#for child in get_children():
		#if child is CollisionPolygon2D:
			#var new_poly = CollisionPolygon2D.new()
			#new_poly.polygon = child.polygon
			#slowdown_zone.add_child(new_poly)


#func _physics_process(delta: float) -> void:
	# watched shape children queued for removal
	#for child in queued:
		#if child != null:
			#child.queue_free()
	#queued.clear()
	# check that destructors overlap with remaining watched area
	#if destructors.size() == 0: return
	#var overlap = active_watch_area.get_overlapping_areas()
	#for destructor in destructors:
		#if overlap.find(destructor) == -1:
			## destructor no longer overlapping watch area
			#destructors.erase(destructor)
			#emit_signal("destructor_exited_watch_area", destructor)
