extends Node

@onready var audio_button_hover: AudioStreamPlayer = $AudioButtonHover
@onready var audio_button_click: AudioStreamPlayer = $AudioButtonClick

func play_button_hover() -> void:
	audio_button_hover.play()

func play_button_click() -> void:
	audio_button_click.play()
