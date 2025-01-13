extends Node2D

var spawn_side = true

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(.07, .09, .09, 1))
		
	var player = preload("res://Player/Player.tscn").instantiate()
	player.position = get_viewport_rect().size / 2
	#player.position = $Arena.spawn_point
	add_child(player)
	#player.destructor.min_spin_speed = 10

	spawn_destructible()
	
	var powerup = preload("res://Entity/Powerup.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(600, 820), randi_range(80, 300))
	powerup.position = spawn_loc
	add_child(powerup)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		spawn_destructible()

func spawn_destructible():
	var new_destructible = preload("res://Entity/DestructibleEntity.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(180, 480), randi_range(180, 520))
	if spawn_side == true:
		spawn_loc = Vector2(spawn_loc.x + 940, spawn_loc.y)
	spawn_side = !spawn_side
	new_destructible.position = spawn_loc
	add_child(new_destructible)
	new_destructible.was_destroyed.connect(spawn_destructible)
