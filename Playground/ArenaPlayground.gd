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
	#player.transform = Vector2(.2, .2)
	#var t = Transform2D(0, Vector2(.2, .2), 0, $Arena.spawn_point)
	
	player.position = $Arena.spawn_point
	
	add_child(player)
	player.entity_scale = Vector2(.2, .2)

	#player.entity_scale = Vector2(.2, .2)
	#player.hitbox.scale = Vector2(.2, .2)
	#player.destructor.apply_scale(Vector2(.2, .2))

func ping(node) -> void:
	print("ping", node)
