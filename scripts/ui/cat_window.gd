class_name CatWindow
extends Panel

signal closed

@export var sprite_texture_happy: Texture2D = preload("res://textures/ui/icon-cat-happy.png")
@export var sprite_texture_sad: Texture2D = preload("res://textures/ui/icon-cat-sad.png")

@onready var name_label: Label = $Name
@onready var description_label: Label = $Description
@onready var activity_label: Label = $ActivityLabel
@onready var icon_hungry: TextureRect = $IconHungry
@onready var icon_thirsty: TextureRect = $IconThirsty
@onready var icon_bored: TextureRect = $IconBored
@onready var icon_tired: TextureRect = $IconTired

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
	if visible:
		hide()
		closed.emit()
		if cat != null:
			cat.on_window_closed()

func set_state(icon: TextureRect, state: bool) -> void:
	if state && icon.texture != sprite_texture_sad:
		icon.texture = sprite_texture_sad
	elif !state && icon.texture != sprite_texture_happy:
		icon.texture = sprite_texture_happy

func set_states(is_hungry: bool, is_thirsty: bool, is_bored: bool, is_tired: bool) -> void:
	set_state(icon_hungry, is_hungry)
	set_state(icon_thirsty, is_thirsty)
	set_state(icon_bored, is_bored)
	set_state(icon_tired, is_tired)

func set_activity(activity: String) -> void:
	activity_label.text = activity

func _on_button_close_pressed() -> void:
	close()
