class_name CatWindow
extends Panel

@onready var name_label: Label = $Name
@onready var description_label: Label = $Description
@onready var activity_label: Label = $ActivityLabel

var cat: Cat

func open(selected_cat: Cat) -> void:
	visible = true
	if cat != null:
		cat.on_window_closed()
	cat = selected_cat
	cat.open_window = self
	name_label.text = cat.cat_name
	description_label.text = cat.cat_description
	activity_label.text = cat.get_current_activity()

func close() -> void:
	visible = false
	if cat != null:
		cat.on_window_closed()

func set_activity(activity: String) -> void:
	activity_label.text = activity

func _on_button_close_pressed() -> void:
	close()