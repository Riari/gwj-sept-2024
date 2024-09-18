class_name BaseItem
extends Node2D

@onready var interaction_area: Area2D = $Item/InteractionArea

func on_place() -> void:
	place_down_particles.emitting = true
	place_down_audio.play()

func disable_areas():
	platform_surface_area.process_mode = Node.PROCESS_MODE_DISABLED
	platform_area.process_mode = Node.PROCESS_MODE_DISABLED

func enable_areas():
	platform_surface_area.process_mode = Node.PROCESS_MODE_INHERIT
	platform_area.process_mode = Node.PROCESS_MODE_INHERIT
