class_name AchievementsWindow
extends Panel

signal closed

func open() -> void:
	if !visible:
		show()

func close() -> void:
	if visible:
		hide()
		closed.emit()