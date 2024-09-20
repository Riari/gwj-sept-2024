extends StaticBody2D

func _on_platform_surface_body_entered(body:Node2D) -> void:
	if body.get_groups().has("cat"):
		body.disable_freshly_spawned_mode()
