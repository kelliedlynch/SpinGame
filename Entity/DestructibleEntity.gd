extends RigidPolygonEntity
class_name DestructibleEntity

@onready var destruction_area: DestructionArea = $RigidBody/DestructionArea
@onready var destruction_polygon: CollisionPolygon2D = $RigidBody/DestructionArea/DestructionPolygon

var destroying = false

var clip_next_tick: PackedVector2Array = []
var clip_queue: Array[PackedVector2Array] = []
var clip_timer = 5
var clip_timer_elapsed = 0

func _ready() -> void:
	super._ready()
	body.body_entered.connect(_on_body_entered)
	body.body_exited.connect(_on_body_exited)
	destruction_area.area_entered.connect(_on_area_entered)
	destruction_area.area_exited.connect(_on_area_exited)
	

#func destruct(destroyer: CollisionPolygon2D):
	## check if doing for loops on the packed arrays is faster
	##var expanded = Geometry2D.offset_polygon($DestructionArea/Hitbox.polygon, .1)
	#var thispoly = Array($RigidBody/DestructionArea/Hitbox.polygon).map(func(x): return $RigidBody/DestructionArea.to_global(x))
	##var d = Geometry2D.offset_polygon(destroyer.polygon, 5)
	##var clipping = Geometry2D.offset_polygon(destroyer.polygon, -.1)
	#var dpoly = Array(destroyer.polygon).map(func(x): return destroyer.get_parent().to_global(x))
	#var results = Geometry2D.clip_polygons(thispoly, dpoly)
	#if results.size() > 0:
		#clip_next_tick = results[0]
	##$VisibleObject/Polygon.polygon = Array(results[0]).map(func(x): return $VisibleObject/Polygon.to_local(x))
	##$DestructionArea/Hitbox.polygon = Array(results[0]).map(func(x): return $DestructionArea/Hitbox.to_local(x))
	
func apply_destructor(destructor: Destructor):
	#var this_poly = Array(hitbox.polygon).map(func(x): return body.to_global(x))
	var destructor_relative_to_this: PackedVector2Array = []
	for pt in destructor.destruct_polygon.polygon:
		destructor_relative_to_this.append(body.to_local((destructor.destruct_polygon.to_global(pt))))
	#var destructor_poly = Array(destructor.destruct_polygon.polygon).map(func(x): return destructor.destruct_polygon.to_global(x))

	var clipped = Geometry2D.clip_polygons(hitbox.polygon, destructor_relative_to_this)
	#hitbox.polygon = clipped
	#var local = Array(clipped[0]).map(func(x): return body.to_local(x))
	visible_polygon.polygon = clipped[0]
	hitbox.polygon = clipped[0]
	clip_queue.append(clipped[0])
	pass
	#
	#
func _on_area_entered(node):
	if !(node is Destructor): return
	print("set destroying true")
	destroying = true
	#apply_destructor(node)
	
func _on_area_exited(node):
	if !(node is Destructor): return
	print("set destroying false")
	destroying = false

func _on_body_entered(node):
	pass
	
func _on_body_exited(node):
	pass

#func _physics_process(delta: float) -> void:
	#if !destroying: return
	#for node in destruction_area.get_overlapping_areas():
		#if node is not Destructor: return
		#apply_destructor(node)
			
func _process(delta: float) -> void:
	if clip_queue.size() > 0:
		if clip_timer_elapsed > clip_timer:
			#var clipped = Array(clip_queue.pop_front()).map(func (x): return destruction_area.to_local(x))
			#var local: PackedVector2Array = []
			#for pt in clip_queue.pop_front():
				#local.append(destruction_area.to_local(pt))
			destruction_polygon.polygon = clip_queue.pop_front()
		clip_timer_elapsed += 1
	elif clip_timer_elapsed > 0:
		clip_timer_elapsed = 0
		
	if !destroying: return
	for node in destruction_area.get_overlapping_areas():
		if !(node is Destructor): continue
		apply_destructor(node)
		
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#for i in state.get_contact_count():
		#print(self, state.get_contact_collider_position(i))
