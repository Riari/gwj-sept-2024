extends Node2D

@onready var fader: Fader = $HUD/Fader

func _ready() -> void:
	MusicManager.start_playlist([1, 2], 10.0)
	fader.fade_in()