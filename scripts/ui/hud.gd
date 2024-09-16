extends CanvasLayer

@onready var button_hover_sound: AudioStreamPlayer = get_node("ButtonHoverSound")
@onready var button_click_sound: AudioStreamPlayer = get_node("ButtonClickSound")

func _on_button_mouse_entered() -> void:
	button_hover_sound.play()

func _on_button_pressed() -> void:
	button_click_sound.play()
