extends Node2D

@export var cat_state: Cat.State

@onready var sprite: Sprite2D = $Sprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var place_down_audio: AudioStreamPlayer2D = $PlaceDownAudio

var mouse_default = load("res://textures/cursors/arrow.png")
var mouse_point = load("res://textures/cursors/point.png")

var item_data = {}
var sprite_texture: Texture2D
var sprite_texture_depleted: Texture2D

var in_use = false
var uses_remaining = 0

func configure(data: Dictionary) -> void:
	item_data = data
	uses_remaining = data["MaxUses"]
	sprite_texture = load(data["Sprite"])
	sprite.texture = sprite_texture
	if data.has("SpriteDepleted"):
		sprite_texture_depleted = load(data["SpriteDepleted"])

func enable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_INHERIT

func disable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_DISABLED

func on_place() -> void:
	place_down_audio.play()

func on_finished_using() -> void:
	in_use = false
	if uses_remaining == 0:
		sprite.texture = sprite_texture_depleted

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if uses_remaining > 0 && !in_use && body.get_groups().has("cat"):
		if body.tempt_action(self, cat_state, interaction_area.global_position):
			in_use = true
			uses_remaining -= 1

func _on_interaction_area_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_point)

func _on_interaction_area_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(mouse_default)
