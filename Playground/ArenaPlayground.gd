extends Node2D

#@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	#$Arena.remove_child($Arena/ArenaPhysicsArea)
	var new_destructible = DestructibleEntity.create_new()
	new_destructible.position = Vector2(300, 400)
	#new_destructible.update_polygons()
	add_child(new_destructible)
	var player = preload("res://Player/Player.tscn").instantiate()

	player.position = get_viewport_rect().size / 2
	#player.position = $Arena.spawn_point
	player.entity_scale = Vector2(.1, .1)
	add_child(player)
	#player.entity_scale = Vector2(.2, .2)
	player.update_scale(Vector2(.1, .1))

func ping(node) -> void:
	print("ping", node)
