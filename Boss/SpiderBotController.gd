extends BossController

func _ready() -> void:
	max_health = 200
	current_health = 200
	atk_speed = 1.5
	#attacks.append(JumpAndSmash.new(boss, self))
	#attacks.append(LaserBeam.new(boss, self))
	attacks.append(AreaMissile.new(boss, self))
	attacks.append(RollAround.new(boss, self))
	super._ready()
	
