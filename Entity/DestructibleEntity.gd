extends RigidPolygonEntity
class_name DestructibleEntity

var destroying = false

var clip_next_tick: PackedVector2Array = []

func _ready() -> void:
	super._ready()
	body.body_entered.connect(_on_body_entered)

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
	#
	#
func _on_body_entered(node: Destructor):
	if !(node is Destructor): return
	print("poing")
	#
#func _on_destruct_area_entered(node):
	##if node.get_parent() is Player:
		##destruct(node.get_node("Hitbox"))
	#destroying = true
	#print(node)
#
#func _on_destruct_area_exited(node):
	#destroying = false
	#print(node, " exited")
#
#func _physics_process(delta: float) -> void:
	#if !clip_next_tick.is_empty():
		#var clip = Array(clip_next_tick)
		##$RigidBody/VisibleObject/Polygon.polygon = clip.map(func(x): return $RigidBody/VisibleObject.to_local(x))
		##$DestructionArea/Hitbox.polygon = clip.map(func(x): return $DestructionArea.to_local(x))
		##$RigidBody/Hitbox.polygon = clip.map(func(x): return $RigidBody.to_local(x))
		#clip_next_tick.clear()
	#if !destroying: return
	#var b = $RigidBody/DestructionArea.get_overlapping_bodies()
	#for body in b:
		#if body.get_parent() is Player:
			#destruct(body.get_parent().get_node("RigidBody/DestructArea/DestructPolygon"))
			#return
			
#func _process(delta: float) -> void:
	#$DestructionArea
