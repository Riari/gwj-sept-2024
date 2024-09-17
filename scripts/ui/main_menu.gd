extends Control

@onready var button_quit = get_node("ButtonQuit")

func _ready() -> void:
	if OS.get_name() == "Web":
		button_quit.hide()

func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ingame.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()
