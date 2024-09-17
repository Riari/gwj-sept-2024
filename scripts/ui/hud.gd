extends CanvasLayer

@onready var button_hover_sound: AudioStreamPlayer = get_node("ButtonHoverSound")
@onready var button_click_sound: AudioStreamPlayer = get_node("ButtonClickSound")
@onready var shop_window: Control = $ShopWindow

func _on_button_mouse_entered() -> void:
	button_hover_sound.play()

func _on_button_pressed() -> void:
	button_click_sound.play()

func _on_button_shop_pressed() -> void:
	shop_window.visible = !shop_window.visible
