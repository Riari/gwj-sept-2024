class_name CatWindow
extends Panel

@onready var name_label: Label = $Name
@onready var description_label: Label = $Description

var cat: Cat

func open(selected_cat: Cat) -> void:
	visible = true
	cat = selected_cat
	name_label.text = cat.cat_name
	description_label.text = cat.cat_description

func _on_button_close_pressed() -> void:
	visible = false
