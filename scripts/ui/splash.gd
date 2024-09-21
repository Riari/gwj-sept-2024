extends Control

@onready var fader: Fader = $Fader

func _ready() -> void:
	get_node("/root/MusicManager").play(0)
	fader.connect("fade_out_complete", _on_fade_out_complete)

func _on_fade_out_complete() -> void:
	get_tree().change_scene_to_file("res://scenes/main-menu.tscn")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	fader.fade_out()