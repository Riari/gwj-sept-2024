class_name Notification
extends Control

signal selected

@onready var label_title: Label = $Panel/Button/TitleLabel
@onready var label_description: Label = $Panel/Button/DescriptionLabel

var type: Notifications.NotificationType
var display_time = 5.0

func init(notification_type: Notifications.NotificationType, title: String, description: String) -> void:
	type = notification_type
	label_title.text = title
	label_description.text = description

func _process(delta: float) -> void:
	display_time -= delta

	if display_time <= 0.0:
		queue_free()

func _on_button_pressed() -> void:
	SoundEffectManager.play_button_click()
	selected.emit(type)
	queue_free()
