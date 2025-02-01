extends Node

@onready var audio: AudioStreamPlayer = $AnimationSounds
var missile_explode: AudioStreamOggVorbis = load("res://Audio/explosionCrunch_003.ogg")

func _on_missile_landed():
	audio.stream = missile_explode
	audio.play()
