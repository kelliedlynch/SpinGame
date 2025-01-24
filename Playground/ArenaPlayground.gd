extends Node

var spawn_side = true
#var player: Player
#var boss: BossMonster
var powerup_timer = 0
var powerup: Powerup = null
@onready var pg_overlay: PlaygroundOverlay = $PlaygroundOverlay

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(.17, .18, .2, 1))
	pg_overlay.player_btn.button_down.connect(Player.spawn_to_arena.bind($Arena))
	BattleManager.spawn_boss_to_arena(null, $Arena)
	pg_overlay.boss_btn.button_down.connect(BattleManager.spawn_boss_to_arena.bind(null, $Arena))
	#Player.spawn_to_arena($Arena)
	#spawn_boss()
	spawn_powerup()
	BattleManager.spawn_player_to_arena($Arena)
	BattleManager.begin_battle()

	
func spawn_powerup():
	powerup = preload("res://Entity/Powerup.tscn").instantiate()
	var spawn_loc = Vector2(randi_range(600, 820), randi_range(100, 300))
	spawn_loc.y = spawn_loc.y if randi() % 2 == 0 else $Arena.get_viewport_rect().size.y - spawn_loc.y
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

#func spawn_boss():

	#boss.add_to_arena($Arena)
	#boss.tree_exited.connect(spawn_destructible)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
