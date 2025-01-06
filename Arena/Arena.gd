extends Node

var spawn_point: Vector2

func _ready() -> void:
	spawn_point = get_viewport().size / 2
