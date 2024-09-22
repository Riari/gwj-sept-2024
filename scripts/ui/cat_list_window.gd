class_name CatListWindow
extends Panel

signal closed
signal selected_cat(cat: Cat)

@export var cat_list_item_scene: PackedScene = preload("res://scenes/ui/cat-list-item.tscn")

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

var cat_register: Array[Cat]

func open() -> void:
	if !visible:
		show()

func close() -> void:
	if visible:
		hide()
		closed.emit()

func register_cat(cat: Cat) -> void:
	cat_register.push_back(cat)
	var cat_list_item = cat_list_item_scene.instantiate()
	grid_container.add_child(cat_list_item)
	cat_list_item.connect("selected", _on_cat_list_item_selected)
	cat_list_item.init(cat_register.size() - 1, cat.cat_name, cat.cat_description, cat.cat_profile_image)

func _on_cat_list_item_selected(cat_index: int) -> void:
	selected_cat.emit(cat_register[cat_index])
	close()

func _on_button_close_pressed() -> void:
	close()
