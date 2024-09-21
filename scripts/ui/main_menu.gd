extends Control

@onready var button_quit: Button = $ButtonQuit
@onready var fader: Fader = $Fader
@onready var settings: ColorRect = $Settings
@onready var credits: ColorRect = $Credits

func _ready() -> void:
	if OS.get_name() == "Web":
		button_quit.hide()

	fader.connect("fade_out_complete", _on_fade_out_complete)
	fader.fade_in()

func _on_fade_out_complete() -> void:
	get_tree().change_scene_to_file("res://scenes/ingame.tscn")

func _on_button_mouse_entered() -> void:
	SoundEffectManager.play_button_hover()

func _on_button_pressed() -> void:
	SoundEffectManager.play_button_click()

func _on_button_play_pressed() -> void:
	fader.fade_out()
	MusicManager.fade_out()

func _on_button_quit_pressed() -> void:
	get_tree().quit()

func _on_button_settings_pressed() -> void:
	settings.visible = true

func _on_button_credits_pressed() -> void:
	credits.visible = true

func _on_button_back_to_main_menu_pressed() -> void:
	settings.visible = false
	credits.visible = false
