class_name Hints
extends ColorRect

enum Trigger
{
	PANNED_CAMERA,
	OPENED_SHOP,
	PLACED_TOWER,
	PLACED_ITEM,
	CLOSED_CAT_PROFILE,
	CLOSED_CAT_LIST,
}

var triggers = {
	Trigger.PANNED_CAMERA: 1,
	Trigger.OPENED_SHOP: 2,
	Trigger.PLACED_TOWER: 3,
	Trigger.PLACED_ITEM: 4,
	Trigger.CLOSED_CAT_PROFILE: 5,
	Trigger.CLOSED_CAT_LIST: 6,
}

var last_hint_shown = 0

func start() -> void:
	if SettingsManager.disable_hints:
		return

	show_hint(0)

func _on_hint_dismissed() -> void:
	get_child(last_hint_shown).hide()
	hide()
	get_tree().paused = false

func show_hint(hint_index: int) -> void:
	if SettingsManager.disable_hints:
		return

	show()
	get_child(hint_index).show()
	last_hint_shown = hint_index
	get_tree().paused = true

func trigger_hint(trigger: Trigger) -> void:
	if triggers.has(trigger):
		show_hint(triggers[trigger])
		triggers.erase(trigger)

func on_panned_camera_all_directions() -> void:
	trigger_hint(Trigger.PANNED_CAMERA)

func on_opened_shop() -> void:
	trigger_hint(Trigger.OPENED_SHOP)

func on_placed_tower() -> void:
	trigger_hint(Trigger.PLACED_TOWER)

func on_placed_item() -> void:
	trigger_hint(Trigger.PLACED_ITEM)

func on_cat_window_closed() -> void:
	trigger_hint(Trigger.CLOSED_CAT_PROFILE)

func on_cat_list_window_closed() -> void:
	trigger_hint(Trigger.CLOSED_CAT_LIST)
