extends CanvasLayer

signal shop_item_purchased(item_data: Dictionary)
signal shop_item_purchase_cancelled

@export var fish_amount_animation_scene = preload("res://scenes/ui/fish-amount-animation.tscn")

@onready var toolbar: GridContainer =  $Toolbar
@onready var button_cancel: Button = $ButtonCancel
@onready var cash_register_sound: AudioStreamPlayer = $CashRegisterSound
@onready var fish_earned_sounds: Node = $FishEarnedSounds
@onready var fish_amount_label: RichTextLabel = $FishTotal/Amount
@onready var shop_window: ShopWindow = $ShopWindow
@onready var cat_window: CatWindow = $CatWindow
@onready var animated_amount_container: Control = $FishTotal/AnimatedAmountContainer
@onready var menu_container: ColorRect = $MenuContainer
@onready var menu: Panel = $MenuContainer/MenuPanel
@onready var menu_button_quit: Button = $MenuContainer/MenuPanel/MenuButtonQuit
@onready var quit_confirmation: Panel = $MenuContainer/QuitConfirmationPanel
@onready var settings_panel: ColorRect = $SettingsPanel
@onready var hints: Hints = $Hints
@onready var shop_hint_arrow: Control = $HintArrows/ShopHintArrow

var has_purchased_item = false
var is_placing_item = false
var last_purchased_item_data: Dictionary
var fish_total = 0

func _ready() -> void:
	if OS.get_name() == "Web":
		menu_button_quit.hide()
	
	if !SettingsManager.disable_hints:
		hints.start()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.is_action("cancel"):
			if shop_window.visible:
				shop_window.visible = false
			else:
				menu_container.visible = !menu_container.visible
				menu.visible = menu_container.visible
				quit_confirmation.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_shop"):
		if shop_window.visible:
			shop_window.close()
		else:
			shop_hint_arrow.hide()
			shop_window.open()
			cat_window.close()
	
	if has_purchased_item && !is_placing_item && Input.is_action_just_pressed("repeat_purchase") && fish_total >= last_purchased_item_data["Price"]:
		shop_window.close()
		cash_register_sound.play()
		shop_item_purchased.emit(last_purchased_item_data)

func _on_button_mouse_entered() -> void:
	SoundEffectManager.play_button_hover()

func _on_button_pressed() -> void:
	SoundEffectManager.play_button_click()

func _on_button_shop_pressed() -> void:
	shop_window.visible = !shop_window.visible
	if shop_window.visible:
		shop_hint_arrow.hide()
		cat_window.close()

func _on_button_menu_pressed() -> void:
	menu_container.visible = true
	menu.visible = true
	quit_confirmation.visible = false

func _on_menu_button_return_to_game_pressed() -> void:
	menu_container.visible = false

func _on_button_quit_confirm_pressed() -> void:
	get_tree().quit()

func _on_button_quit_cancel_pressed() -> void:
	quit_confirmation.visible = false
	menu_container.visible = false

func _on_menu_button_quit_pressed() -> void:
	menu.visible = false
	quit_confirmation.visible = true

func _on_menu_button_settings_pressed() -> void:
	settings_panel.visible = true

func _on_button_cancel_pressed() -> void:
	shop_item_purchase_cancelled.emit()

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
	is_placing_item = true
	button_cancel.visible = true
	disable_toolbar()

func _on_item_manager_finished_item_placing() -> void:
	is_placing_item = false
	button_cancel.visible = false
	enable_toolbar()

func _on_item_manager_item_cancellation_confirmed() -> void:
	is_placing_item = false
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

func _on_hint_1_dismissed() -> void:
	shop_hint_arrow.show()
