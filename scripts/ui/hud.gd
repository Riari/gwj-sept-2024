extends CanvasLayer

signal shop_item_purchased(item_data: Dictionary)
signal shop_item_purchase_cancelled

@export var fish_amount_animation_scene = preload("res://scenes/ui/fish-amount-animation.tscn")

@onready var toolbar: GridContainer =  $Toolbar
@onready var button_cancel: Button = $ButtonCancel
@onready var button_hover_sound: AudioStreamPlayer = $ButtonHoverSound
@onready var button_click_sound: AudioStreamPlayer = $ButtonClickSound
@onready var fish_earned_sounds: Node = $FishEarnedSounds
@onready var fish_amount: RichTextLabel = $FishTotal/Amount
@onready var shop_window: Control = $ShopWindow
@onready var cat_window: CatWindow = $CatWindow
@onready var animated_amount_container: Control = $FishTotal/AnimatedAmountContainer

func _on_button_mouse_entered() -> void:
	button_hover_sound.play()

func _on_button_pressed() -> void:
	button_click_sound.play()

func _on_button_shop_pressed() -> void:
	shop_window.visible = !shop_window.visible

func _on_item_manager_fish_changed(total: int, adjustment: int) -> void:
	fish_amount.text = str(total)

	if adjustment != 0:
		var anim: FishAmountAnimation = fish_amount_animation_scene.instantiate()
		animated_amount_container.add_child(anim)
		anim.set_amount(adjustment)
		anim.play()
	
	if adjustment > 0:
		fish_earned_sounds.get_children().pick_random().play()

func _on_shop_window_item_purchased(item_data: Dictionary) -> void:
	shop_item_purchased.emit(item_data)

func _on_item_manager_started_item_placing() -> void:
	button_cancel.visible = true
	disable_toolbar()

func _on_item_manager_finished_item_placing() -> void:
	button_cancel.visible = false
	enable_toolbar()

func _on_button_cancel_pressed() -> void:
	shop_item_purchase_cancelled.emit()

func _on_item_manager_item_cancellation_confirmed() -> void:
	button_cancel.visible = false
	enable_toolbar()

func _on_cat_manager_cat_selected(cat: Cat) -> void:
	cat_window.open(cat)

func _on_cat_manager_cat_spawned(cat: Cat) -> void:
	pass # Replace with function body.

func enable_toolbar() -> void:
	for node in toolbar.get_children():
		node.disabled = false

func disable_toolbar() -> void:
	for node in toolbar.get_children():
		node.disabled = true
