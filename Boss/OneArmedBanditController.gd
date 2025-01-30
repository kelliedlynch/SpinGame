extends BossController

func _ready() -> void:
	current_health = max_health
	attacks.append(JumpAndSmash.new(boss, self))
	attacks.append(LaserBeam.new(boss, self))
	attacks.append(AreaMissile.new(boss, self))
	super._ready()
