class_name ItemWindow
extends Panel

signal closed

@onready var label_name: Label = $Name
@onready var label_description: Label = $Description
@onready var uses_remaining_control: Control = $UsesRemaining
@onready var uses_remaining_bar: ProgressBar = $UsesRemaining/ProgressBar
@onready var button_replace: Button = $UsesRemaining/ButtonReplace
@onready var button_sell: Button = $ButtonSell

var item: Item
var fish_total: int

func open(selected_item: Item) -> void:
	if !visible:
		show()

	item = selected_item
	label_name.text = item.definition["Name"]
	label_description.text = item.definition["Description"]
	button_sell.text = "Sell for %d" % int(item.definition["Price"] / 2)

	if item.uses_remaining > -1:
		uses_remaining_control.show()
		uses_remaining_bar.max_value = item.definition["MaxUses"]
		button_replace.text = "Replace for %d" % item.definition["ReplacePrice"]
		set_uses_remaining(item.uses_remaining)
		item.open_window = self
	else:
		if item != null:
			item.on_window_closed()
		uses_remaining_control.hide()

func close() -> void:
	if visible:
		hide()
		closed.emit()
		if item != null:
			item.on_window_closed()

func update_replace_button_state() -> void:
	button_replace.disabled = !item.definition.has("ReplacePrice") || item.definition["ReplacePrice"] > fish_total || uses_remaining_bar.value == uses_remaining_bar.max_value

func set_uses_remaining(uses_remaining: int) -> void:
	uses_remaining_bar.value = uses_remaining
	update_replace_button_state()

func on_fish_changed(fish: int) -> void:
	fish_total = fish
	if visible:
		update_replace_button_state()

func _on_button_replace_pressed() -> void:
	item.replace()

func _on_button_sell_pressed() -> void:
	item.sell()
	close()

func _on_button_close_pressed() -> void:
	close()
