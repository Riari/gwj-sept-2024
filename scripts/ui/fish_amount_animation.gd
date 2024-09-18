class_name FishAmountAnimation
extends Control

@export var color_positive = Color(.35, .9, .9, 1)
@export var color_negative = Color(1, .7, .78, 1)

@onready var amount_label: RichTextLabel = $AmountLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func set_amount(amount: int) -> void:
	amount_label.clear()
	amount_label.push_color(color_positive if amount > 0.0 else color_negative)
	amount_label.append_text(str(amount))
	amount_label.pop()

func play() -> void:
	animation_player.current_animation = "fish_amount_animation"
	animation_player.play()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
