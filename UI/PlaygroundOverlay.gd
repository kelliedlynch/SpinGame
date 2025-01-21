extends Control
class_name PlaygroundOverlay

@onready var playground: Node = get_parent()
@onready var boss_btn: Button = $MarginContainer/HBoxContainer/action_buttons/respawn_boss_button
@onready var player_btn: Button = $MarginContainer/HBoxContainer/action_buttons/respawn_player_button

func _ready() -> void:
	pass
