extends Node2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var place_down_audio: AudioStreamPlayer2D = $PlaceDownAudio

func enable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_INHERIT

func disable_areas():
	interaction_area.process_mode = Node.PROCESS_MODE_DISABLED

func on_place() -> void:
	place_down_audio.play()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.get_groups().has("cat"):
		body.tempt_action(Cat.State.LOAF, interaction_area.global_position)
