extends Node2D

signal platform_area_entered
signal platform_area_exited

func _on_mouse_entered() -> void:
	platform_area_entered.emit()

func _on_mouse_exited() -> void:
	platform_area_exited.emit()
