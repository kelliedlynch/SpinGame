#@tool
extends AspectRatioContainer

@onready var player_health_bar: TextureProgressBar = $VBoxContainer/footer/HBoxContainer/health_bar

func _init() -> void:
	name = "BattleOverlay"
	z_index = RenderLayer.BATTLE_OVERLAY


#func _ready() -> void:
	#var a = owner
	#var b = get_child(0).owner
	#pass

func _on_player_health_changed(current: int, max_val: int):
	player_health_bar.max_value = max_val
	player_health_bar.value = current
	pass
