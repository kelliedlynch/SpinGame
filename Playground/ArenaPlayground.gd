extends Node2D

#@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	#$Arena.remove_child($Arena/ArenaPhysicsArea)
	var new_destructible = preload("res://Entity/DestructibleEntity.tscn").instantiate()
	new_destructible.position = Vector2(300, 400)
	
	#new_destructible.entity_scale = Vector2(1.5, 1.5)
	#new_destructible.update_all_polygons([PolygonMath.DEFAULT_POLYGON])
	add_child(new_destructible)
	var player = preload("res://Player/Player.tscn").instantiate()

	player.position = get_viewport_rect().size / 2
	#player.position = $Arena.spawn_point
	player.entity_scale = Vector2(.1, .1)
	add_child(player)
	#player.entity_scale = Vector2(.2, .2)
	#player.update_scale(Vector2(.3, .3))


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var new_destructible = preload("res://Entity/DestructibleEntity.tscn").instantiate()
		new_destructible.position = Vector2(300, 400)
		add_child(new_destructible)
