extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	#$Player.position = $Arena.spawn_point
	var w = 160
	var h = 280
	var rect = [Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)]
	var new_destructible = DestructibleEntity.create_new()
	new_destructible.position = Vector2(300, 200)
	add_child(new_destructible)
	var player = preload("res://Player/Player.tscn").instantiate()
	##player.transform = Vector2(.2, .2)
	##var t = Transform2D(0, Vector2(.2, .2), 0, $Arena.spawn_point)
	#
	##player.position = $Arena.spawn_point
	player.position = get_viewport_rect().size / 2
	#
	$Arena.add_child(player)
	player.entity_scale = Vector2(.2, .2)

	#player.entity_scale = Vector2(.2, .2)
	#player.hitbox.scale = Vector2(.2, .2)
	#player.destructor.apply_scale(Vector2(.2, .2))
	
	#var saw = PolygonMath.load_polygon(PolygonVertexData.saw_blade)
	#var polysize = PolygonMath.size_of_polygon(saw)
	#var circle = PolygonMath.generate_circle_polygon(polysize.x / 2)
	#var p = $Player
	#var a: Array[PackedVector2Array] = []
	#a.append(circle)
	#$Player.polygons = a
	#var v: Array[PackedVector2Array] = []
	#v.append(saw)
	#$Player.visible_area.polygons = v
	#var d: Array[PackedVector2Array] = []
	#d.append(circle)
	#$Player.destructor.polygons = d

func ping(node) -> void:
	print("ping", node)
