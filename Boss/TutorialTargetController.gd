extends BossController

func _ready() -> void:
	max_health = 1
	current_health = max_health
	attacks.append(DoNothing.new(boss, self))
	super._ready()
