extends Node

@onready var music: AudioStreamPlayer = $MusicPlayer

var phase1: AudioStreamOggVorbis = load("res://Audio/Ludum Dare 28 08.ogg")
var phase2: AudioStreamOggVorbis = load("res://Audio/VGMA Challenge 20.ogg")


func _ready() -> void:
	BattleManager.battle_beginning.connect(_on_battle_beginning)
	BattleManager.battle_ended.connect(_on_battle_ended)
	BattleManager.phase_changed.connect(_on_phase_change)

func _on_battle_beginning():
	music.stream = phase1
	music.play()

func _on_phase_change():
	music.stream = phase2
	music.play()

func _on_battle_ended():
	#music.stop()
	pass
