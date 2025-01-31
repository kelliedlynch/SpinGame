extends BossMonster
class_name OneArmedBandit

@onready var audio_manager: Node = $AudioManager

func _ready() -> void:
	boss_name = "One-Armed Bandit"
	super._ready()
