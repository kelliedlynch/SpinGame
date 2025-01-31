extends BossController

#@onready var sfx: AudioStreamPlayer = $AudioManagAudioStreamPlayer
#var missile: AreaMissile

func _ready() -> void:
	current_health = max_health
	attacks.append(JumpAndSmash.new(boss, self))
	attacks.append(LaserBeam.new(boss, self))
	var missile = AreaMissile.new(boss, self)
	missile.missile_landed.connect(_on_missile_landed)
	attacks.append(missile)
	super._ready()

func _on_missile_landed():
	boss.audio_manager._on_missile_landed()
