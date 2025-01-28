extends BossController

func _ready() -> void:
	#attacks.append(JumpAndSmash.new(boss, self))
	#attacks.append(LaserBeam.new(boss, self))
	attacks.append(RollAround.new(boss, self))
	super._ready()
	
