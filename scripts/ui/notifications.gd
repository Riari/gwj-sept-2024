class_name Notifications
extends Control

enum NotificationType
{
	ACHIEVEMENT,
	CAT_SPAWNED,
}

signal notification_selected(type: String)

@export var notification_scene: PackedScene = preload("res://scenes/ui/notification.tscn")

@onready var grid_container: GridContainer = $GridContainer

func add_notification(type: NotificationType, title: String, description: String) -> void:
	var notification_node: Notification = notification_scene.instantiate()
	grid_container.add_child(notification_node)
	grid_container.move_child(notification_node, 0)
	notification_node.init(type, title, description)
	notification_node.selected.connect(_on_notification_selected)

func _on_notification_selected(type: NotificationType) -> void:
	notification_selected.emit(type)