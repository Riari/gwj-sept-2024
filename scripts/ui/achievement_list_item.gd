class_name AchievementListItem
extends Control

@onready var label_title: Label = $TitleLabel
@onready var label_description: Label = $DescriptionLabel

func init(title: String, description: String) -> void:
	label_title.text = title
	label_description.text = description