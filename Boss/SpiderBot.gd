extends BossMonster
class_name SpiderBot

@onready var damage_bolts: Node2D = $DamageBolts

func _ready() -> void:
	boss_name = "SpiderBot"
	super._ready()
