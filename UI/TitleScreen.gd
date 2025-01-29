@tool
extends Control

func _ready() -> void:
	$googly_eyes.process_mode = Node.PROCESS_MODE_INHERIT

func _process(delta: float) -> void:
	$saw_blade.rotate(-.05)


func _on_button_pressed() -> void:
	BattleManager.begin_game()
