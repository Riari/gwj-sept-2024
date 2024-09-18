extends CanvasLayer

signal shop_item_purchased(item_data: Dictionary)

@export var fish_amount_animation_scene = preload("res://scenes/ui/fish-amount-animation.tscn")

@onready var toolbar: GridContainer =  $Toolbar
@onready var button_hover_sound: AudioStreamPlayer = $ButtonHoverSound
@onready var button_click_sound: AudioStreamPlayer = $ButtonClickSound
@onready var fish_amount: RichTextLabel = $FishTotal/Amount
@onready var shop_window: Control = $ShopWindow
@onready var animated_amount_container: Control = $FishTotal/AnimatedAmountContainer

func _on_button_mouse_entered() -> void:
	button_hover_sound.play()

func _on_button_pressed() -> void:
	button_click_sound.play()

func _on_button_shop_pressed() -> void:
	shop_window.visible = !shop_window.visible

func _on_item_manager_fish_changed(quantity: int) -> void:
	fish_amount.text = str(quantity)

func _on_shop_window_item_purchased(item_data: Dictionary) -> void:
	shop_item_purchased.emit(item_data)

	var anim: FishAmountAnimation = fish_amount_animation_scene.instantiate()
	animated_amount_container.add_child(anim)
	anim.set_amount(-item_data["Price"])
	anim.play()

func _on_item_manager_started_item_placing() -> void:
	for node in toolbar.get_children():
		node.disabled = true

func _on_item_manager_finished_item_placing() -> void:
	for node in toolbar.get_children():
		node.disabled = false
