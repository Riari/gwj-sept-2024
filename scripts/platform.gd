extends Node2D

signal platform_area_entered
signal platform_area_exited

@export var area_jump_destination = "JumpDestination"

func _on_mouse_entered() -> void:
	platform_area_entered.emit()

func _on_mouse_exited() -> void:
	platform_area_exited.emit()

func _on_platform_surface_area_body_entered(body: Node2D) -> void:
	pass

func _on_platform_surface_area_body_exited(body: Node2D) -> void:
	pass

func _on_platform_surface_area_area_entered(area: Area2D) -> void:
	if area.name == area_jump_destination:
		area.get_parent().call("on_jump_destination_entered_valid_area")

func _on_platform_surface_area_area_exited(area: Area2D) -> void:
	if area.name == area_jump_destination:
		area.get_parent().call("on_jump_destination_exited_valid_area")
