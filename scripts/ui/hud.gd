extends CanvasLayer

signal shop_item_purchased(item_data: Dictionary)
signal shop_item_purchase_cancelled
signal cat_selected(cat: Cat)

@export var fish_amount_animation_scene = preload("res://scenes/ui/fish-amount-animation.tscn")

@onready var toolbar: GridContainer =  $Toolbar
@onready var button_cancel: Button = $ButtonCancel
@onready var cash_register_sound: AudioStreamPlayer = $CashRegisterSound
@onready var fish_earned_sounds: Node = $FishEarnedSounds
@onready var fish_amount_label: RichTextLabel = $FishTotal/Amount

# TODO: Centralise window management
@onready var window_shop: ShopWindow = $ShopWindow
@onready var window_cat: CatWindow = $CatWindow
@onready var window_cat_list: CatListWindow = $CatListWindow
@onready var window_achievements: AchievementsWindow = $AchievementsWindow
@onready var window_item: ItemWindow = $ItemWindow

@onready var hint_arrow_shop: Control = $HintArrows/ShopHintArrow
@onready var hint_arrow_cats: Control = $HintArrows/CatsHintArrow

@onready var notifications: Notifications = $Notifications

@onready var animated_amount_container: Control = $FishTotal/AnimatedAmountContainer
@onready var menu_container: ColorRect = $MenuContainer
@onready var menu: Panel = $MenuContainer/MenuPanel
@onready var menu_button_quit: Button = $MenuContainer/MenuPanel/MenuButtonQuit
@onready var quit_confirmation: Panel = $MenuContainer/QuitConfirmationPanel
@onready var settings_panel: ColorRect = $SettingsPanel
@onready var hints: Hints = $Hints

var has_purchased_something = false
var is_placing_something = false
var last_purchased_item_definition: Dictionary
var fish_total = 0

func _ready() -> void:
	if OS.get_name() == "Web":
		menu_button_quit.hide()

	hints.start()
	AchievementsManager.achievement_unlocked.connect(_on_achievement_unlocked)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.is_action("cancel"):
			if window_shop.visible:
				window_shop.visible = false
			else:
				menu_container.visible = !menu_container.visible
				menu.visible = menu_container.visible
				quit_confirmation.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_shop"):
		if window_shop.visible:
			window_shop.close()
		else:
			hint_arrow_shop.hide()
			hints.on_opened_shop()
			window_shop.open()
			window_cat.close()
			window_cat_list.close()
			window_item.close()
			window_achievements.close()
	
	if has_purchased_something && !is_placing_something && Input.is_action_just_pressed("repeat_purchase") && fish_total >= last_purchased_item_definition["Price"]:
		window_shop.close()
		window_item.close()
		cash_register_sound.play()
		shop_item_purchased.emit(last_purchased_item_definition)

func _on_achievement_unlocked(title: String, description: String) -> void:
	window_achievements.add_achievement(title, description)
	notifications.add_notification(Notifications.NotificationType.ACHIEVEMENT, "Achievement unlocked", title)

func _on_button_mouse_entered() -> void:
	SoundEffectManager.play_button_hover()

func _on_button_pressed() -> void:
	SoundEffectManager.play_button_click()

func _on_button_shop_pressed() -> void:
	if !window_shop.visible:
		window_shop.open()
		hint_arrow_shop.hide()
		hints.on_opened_shop()
		window_cat.close()
		window_cat_list.close()
		window_achievements.close()
		window_item.close()
	else:
		window_shop.close()

func _on_button_cats_pressed() -> void:
	if !window_cat_list.visible:
		window_cat_list.open()
		hint_arrow_cats.hide()
		window_shop.close()
		window_cat.close()
		window_achievements.close()
		window_item.close()
	else:
		window_cat_list.close()

func _on_button_achievements_pressed() -> void:
	if !window_achievements.visible:
		window_achievements.open()
		window_shop.close()
		window_cat.close()
		window_cat_list.close()
		window_item.close()
	else:
		window_achievements.close()

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
	window_shop.on_fish_changed(total)
	if window_item.visible:
		window_item.on_fish_changed(total)

	if adjustment != 0:
		var anim: FishAmountAnimation = fish_amount_animation_scene.instantiate()
		animated_amount_container.add_child(anim)
		anim.set_amount(adjustment)
		anim.play()

	if adjustment > 0:
		fish_earned_sounds.get_children().pick_random().play()

func _on_shop_window_item_purchased(item_definition: Dictionary) -> void:
	has_purchased_something = true
	last_purchased_item_definition = item_definition
	cash_register_sound.play()
	shop_item_purchased.emit(item_definition)

func start_placing_mode() -> void:
	is_placing_something = true
	button_cancel.visible = true
	disable_toolbar()

func stop_placing_mode() -> void:
	is_placing_something = false
	button_cancel.visible = false
	enable_toolbar()

func _on_item_manager_started_placing_tower() -> void:
	start_placing_mode()

func _on_item_manager_started_placing_item() -> void:
	start_placing_mode()

func _on_item_manager_cancelled_placing() -> void:
	stop_placing_mode()

func _on_item_manager_finished_placing_item() -> void:
	stop_placing_mode()
	hints.on_placed_item()

func _on_item_manager_finished_placing_tower() -> void:
	stop_placing_mode()
	hints.on_placed_tower()

func _on_item_manager_finished_item_placing() -> void:
	is_placing_something = false
	button_cancel.visible = false
	enable_toolbar()

func _on_cat_manager_cat_selected(cat: Cat) -> void:
	window_cat.open(cat)

func _on_cat_manager_cat_spawned(cat: Cat) -> void:
	window_cat_list.register_cat(cat)
	notifications.add_notification(Notifications.NotificationType.CAT_SPAWNED, "New arrival", "%s has arrived!" % cat.cat_name)

func _on_player_camera_has_panned_all_directions() -> void:
	hints.on_panned_camera_all_directions()

func enable_toolbar() -> void:
	for node in toolbar.get_children():
		node.disabled = false

func disable_toolbar() -> void:
	for node in toolbar.get_children():
		node.disabled = true

func _on_hint_expects_shop() -> void:
	hint_arrow_shop.show()

func _on_hint_expects_cat_list() -> void:
	hint_arrow_cats.show()

func _on_cat_list_window_selected_cat(cat: Cat) -> void:
	window_cat.open(cat)
	window_item.close()
	cat_selected.emit(cat)

func _on_item_manager_item_selected(item: Item) -> void:
	window_cat.close()
	window_item.open(item)

func _on_notifications_notification_selected(type: Notifications.NotificationType) -> void:
	match type:
		Notifications.NotificationType.ACHIEVEMENT:
			window_cat_list.close()
			window_achievements.open()
		Notifications.NotificationType.CAT_SPAWNED:
			window_achievements.close()
			window_cat_list.open()
