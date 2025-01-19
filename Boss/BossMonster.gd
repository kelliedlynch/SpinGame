extends DestructibleEntity
class_name BossMonsterWithPhysics

@onready var controller: BossController = $BossController

func _ready() -> void:
	super._ready()
	controller.animation_player = $AnimationPlayer
