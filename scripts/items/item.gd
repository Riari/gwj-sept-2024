extends Node2D

@export var cat_state: Cat.State

@onready var sprite: Sprite2D = $Sprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var place_down_audio: AudioStreamPlayer2D = $PlaceDownAudio

var in_use = false

func configure(sprite_texture: Texture2D) -> void:
	sprite.texture = sprite_texture

func enable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_INHERIT

func disable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_DISABLED

func on_place() -> void:
	place_down_audio.play()

func on_finished_using() -> void:
	in_use = false

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if !in_use && body.get_groups().has("cat"):
		body.tempt_action(self, cat_state, interaction_area.global_position)
