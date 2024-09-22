class_name CatListItem
extends Button

signal selected(cat_index: int)

@onready var icon_rect: TextureRect = $Icon
@onready var name_label: Label = $NameLabel

var cat_index: int

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	selected.emit(cat_index)

func init(index: int, cat_name: String, _cat_description: String, cat_profile_image: Texture2D) -> void:
	cat_index = index
	name_label.text = cat_name
	icon_rect.texture = cat_profile_image