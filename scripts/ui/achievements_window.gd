class_name AchievementsWindow
extends Panel

@export var achievement_list_item_scene: PackedScene = preload("res://scenes/ui/achievement-list-item.tscn")

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

signal closed

func open() -> void:
	if !visible:
		show()

func close() -> void:
	if visible:
		hide()
		closed.emit()

func _on_button_close_pressed() -> void:
	close()

func add_achievement(title: String, description: String) -> void:
	var achievement_list_item = achievement_list_item_scene.instantiate()
	grid_container.add_child(achievement_list_item)
	achievement_list_item.init(title, description)
