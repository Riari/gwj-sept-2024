class_name Hints
extends ColorRect

var last_hint_shown = 0

func start() -> void:
	show()
	get_child(0).show()

func _on_hint_dismissed() -> void:
	get_child(last_hint_shown).hide()
	hide()

