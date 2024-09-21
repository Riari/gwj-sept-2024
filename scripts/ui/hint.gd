extends Control

signal dismissed()

func _on_button_mouse_entered() -> void:
	SoundEffectManager.play_button_hover()

func _on_button_pressed() -> void:
	SoundEffectManager.play_button_click()

func _on_check_box_disable_hints_toggled(toggled_on: bool) -> void:
	SettingsManager.disable_hints = toggled_on

func _on_button_ok_pressed() -> void:
	dismissed.emit()
