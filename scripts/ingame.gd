extends Node2D

@onready var fader: Fader = $HUD/Fader

func _ready() -> void:
	MusicManager.fade_in(1)
	fader.fade_in()