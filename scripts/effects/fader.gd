class_name Fader
extends ColorRect

signal fade_in_complete
signal fade_out_complete

@export var color_out := Color(0, 0, 0, 1.0)
@export var color_in := Color(0, 0, 0, 0.0)

const FADE_DURATION = 1.0

var tween: Tween

func on_fade_in_complete() -> void:
	fade_in_complete.emit()
	visible = false

func on_fade_out_complete() -> void:
	fade_out_complete.emit()

func fade(from: Color, to: Color, callback: Callable) -> void:
	if tween:
		tween.kill()
	
	visible = true
	color = from

	tween = create_tween()
	tween.tween_property(self, "color", to, FADE_DURATION).set_trans(Tween.TransitionType.TRANS_SINE)
	tween.tween_callback(callback)

func fade_in() -> void:
	fade(color_out, color_in, on_fade_in_complete)

func fade_out() -> void:
	fade(color_in, color_out, on_fade_out_complete)
	
