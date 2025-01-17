extends Node2D

var spawn_side = true
var player: Player
var destructible: DestructibleEntity
var powerup_timer = 0
var powerup: Powerup = null

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(.07, .09, .09, 1))
		
	player = preload("res://Player/Player.tscn").instantiate()
	player.position = get_viewport_rect().size / 2
	#player.position = $Arena.spawn_point
	add_child(player)
	#player.destructor.min_spin_speed = 10

	spawn_destructible()
	spawn_powerup()
	
func spawn_powerup():
	powerup = preload("res://Entity/Powerup.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(600, 820), randi_range(80, 300))
	powerup.position = spawn_loc
	add_child(powerup)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		spawn_destructible()
	$SpinSpeedLabel.text = str(round_to_dec(player.destructor.spin_speed, 2))
	$MoveSpeedLabel.text = str(int(player.hitbox.linear_velocity.length()))
	$CutPowerLabel.text = str(round_to_dec(player.destructor.cutting_power(), 2))
	if powerup == null:
		if powerup_timer > 1:
			powerup_timer = 0
			spawn_powerup()
		powerup_timer += delta

func spawn_destructible(_node = null):
	destructible = preload("res://Boss/BossMonsterWithPhysics.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(180, 480), randi_range(180, 520))
	if spawn_side == true:
		spawn_loc = Vector2(spawn_loc.x + 940, spawn_loc.y)
	spawn_side = !spawn_side
	destructible.position = spawn_loc
	add_child(destructible)
	destructible.was_destroyed.connect(spawn_destructible)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
