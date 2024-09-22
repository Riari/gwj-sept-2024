class_name Item
extends Node2D

signal selected(item: Item)
signal replaced(item: Item)

@export var cat_state: Cat.State

@onready var sprite: Sprite2D = $Sprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var place_down_audio: AudioStreamPlayer2D = $PlaceDownAudio
@onready var item_depleted_exclamation: Sprite2D = $ItemDepletedExclamation
@onready var item_depleted_animation: AnimationPlayer = $ItemDepletedAnimation

var mouse_default = load("res://textures/cursors/arrow.png")
var mouse_point = load("res://textures/cursors/point.png")

var definition = {}
var sprite_texture: Texture2D
var sprite_texture_depleted: Texture2D

var in_use = false
var uses_remaining = -1 # -1 means infinite

var time_until_pickable = 0.5

var open_window: ItemWindow

func _process(delta: float) -> void:
	if time_until_pickable > 0.0:
		time_until_pickable -= delta
		if time_until_pickable <= 0.0:
			interaction_area.input_pickable = true

func define(item_definition: Dictionary) -> void:
	definition = item_definition
	uses_remaining = definition["MaxUses"]
	sprite_texture = load(definition["Sprite"])
	sprite.texture = sprite_texture
	if definition.has("SpriteDepleted"):
		sprite_texture_depleted = load(definition["SpriteDepleted"])

func enable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_INHERIT

func disable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_DISABLED

func show_depleted_exclamation() -> void:
	item_depleted_exclamation.show()
	item_depleted_animation.active = true
	item_depleted_animation.play()

func hide_depleted_exclamation() -> void:
	item_depleted_animation.stop()
	item_depleted_animation.active = false
	item_depleted_exclamation.hide()

func on_place() -> void:
	place_down_audio.play()

func on_finished_using() -> void:
	in_use = false
	if uses_remaining == 0:
		sprite.texture = sprite_texture_depleted
		show_depleted_exclamation()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if uses_remaining != 0 && !in_use && body.get_groups().has("cat"):
		if body.tempt_action(self, cat_state, interaction_area.global_position):
			in_use = true
			if uses_remaining > 0:
				set_uses_remaining(uses_remaining - 1)

func _on_interaction_area_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_point)

func _on_interaction_area_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(mouse_default)

func _on_interaction_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		selected.emit(self)
		get_viewport().set_input_as_handled()

func on_window_closed() -> void:
	open_window = null

func set_uses_remaining(uses: int) -> void:
	uses_remaining = uses
	if uses != 0:
		hide_depleted_exclamation()
	else:
		show_depleted_exclamation()

	if open_window != null:
		open_window.set_uses_remaining(uses_remaining)

func replace() -> void:
	set_uses_remaining(definition["MaxUses"])
	sprite.texture = sprite_texture
	replaced.emit(self)