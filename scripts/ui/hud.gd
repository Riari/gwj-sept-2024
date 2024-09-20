extends CanvasLayer

signal shop_item_purchased(item_data: Dictionary)
signal shop_item_purchase_cancelled

@export var fish_amount_animation_scene = preload("res://scenes/ui/fish-amount-animation.tscn")

@onready var toolbar: GridContainer =  $Toolbar
@onready var button_cancel: Button = $ButtonCancel
@onready var button_hover_sound: AudioStreamPlayer = $ButtonHoverSound
@onready var button_click_sound: AudioStreamPlayer = $ButtonClickSound
@onready var cash_register_sound: AudioStreamPlayer = $CashRegisterSound
@onready var fish_earned_sounds: Node = $FishEarnedSounds
@onready var fish_amount_label: RichTextLabel = $FishTotal/Amount
@onready var shop_window: ShopWindow = $ShopWindow
@onready var cat_window: CatWindow = $CatWindow
@onready var animated_amount_container: Control = $FishTotal/AnimatedAmountContainer

var has_purchased_item = false
var last_purchased_item_data: Dictionary
var fish_total = 0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_shop"):
		if shop_window.visible:
			shop_window.close()
		else:
			shop_window.open()
			cat_window.close()
	
	if has_purchased_item && Input.is_action_just_pressed("repeat_purchase") && fish_total >= last_purchased_item_data["Price"]:
		shop_window.close()
		cash_register_sound.play()
		shop_item_purchased.emit(last_purchased_item_data)

func _on_button_mouse_entered() -> void:
	button_hover_sound.play()

func _on_button_pressed() -> void:
	button_click_sound.play()

func _on_button_shop_pressed() -> void:
	shop_window.visible = !shop_window.visible

func _on_item_manager_fish_changed(total: int, adjustment: int) -> void:
	var utils = Utils.new()
	fish_total = total
	fish_amount_label.text = utils.number_format(total)
	shop_window.on_fish_changed(total)

	if adjustment != 0:
		var anim: FishAmountAnimation = fish_amount_animation_scene.instantiate()
		animated_amount_container.add_child(anim)
		anim.set_amount(adjustment)
		anim.play()

	if adjustment > 0:
		fish_earned_sounds.get_children().pick_random().play()

func _on_shop_window_item_purchased(item_data: Dictionary) -> void:
	has_purchased_item = true
	last_purchased_item_data = item_data
	cash_register_sound.play()
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
