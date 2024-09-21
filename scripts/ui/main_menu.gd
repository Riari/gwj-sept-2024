extends Control

@onready var button_quit: Button = $ButtonQuit
@onready var fader: Fader = $Fader

func _ready() -> void:
	if OS.get_name() == "Web":
		button_quit.hide()

	fader.connect("fade_out_complete", _on_fade_out_complete)
	fader.fade_in()

func _on_fade_out_complete() -> void:
	get_tree().change_scene_to_file("res://scenes/ingame.tscn")

func _on_button_play_pressed() -> void:
	fader.fade_out()
	MusicManager.fade_out()

func _on_button_quit_pressed() -> void:
	get_tree().quit()
