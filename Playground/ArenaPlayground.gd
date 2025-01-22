extends Node

var spawn_side = true
#var player: Player
var boss: BossMonster
var powerup_timer = 0
var powerup: Powerup = null
@onready var pg_overlay: PlaygroundOverlay = $PlaygroundOverlay

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(.17, .18, .2, 1))
	pg_overlay.player_btn.button_down.connect(Player.spawn_to_arena.bind($Arena))
	pg_overlay.boss_btn.button_down.connect(spawn_boss)
	Player.spawn_to_arena($Arena)
	spawn_boss()
	spawn_powerup()
	
func spawn_powerup():
	powerup = preload("res://Entity/Powerup.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(600, 820), randi_range(80, 300))
	powerup.position = spawn_loc
	add_child(powerup)

func _process(delta: float) -> void:

	$SpinSpeedLabel.text = str(round_to_dec(Player.entity.destructor.spin_speed, 2)) if Player.entity != null else "0"
	$MoveSpeedLabel.text = str(int(Player.entity.hitbox.linear_velocity.length())) if Player.entity != null else "0"
	$CutPowerLabel.text = str(round_to_dec(Player.entity.destructor.get_power(), 2)) if Player.entity != null else "0"
	if powerup == null:
		if powerup_timer > 1:
			powerup_timer = 0
			spawn_powerup()
		powerup_timer += delta

func spawn_boss():
	if boss != null:
		boss.queue_free()
	boss = preload("res://Boss/BossMonster.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(180, 480), randi_range(180, 520))
	if spawn_side == true:
		spawn_loc = Vector2(spawn_loc.x + 940, spawn_loc.y)
	spawn_side = !spawn_side
	boss.position = spawn_loc
	boss.arena = $Arena
	add_child.call_deferred(boss)
	#boss.add_to_arena($Arena)
	#boss.tree_exited.connect(spawn_destructible)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
