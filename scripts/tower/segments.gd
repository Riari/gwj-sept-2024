extends Node2D

@export var packed_scene: PackedScene = preload("res://scenes/partials/tower/segment.tscn")
@export var COLOR_INVALID = Color(1.0, 0.0, 0.25, 0.5)
@export var COLOR_VALID = Color(0.0, 1.0, 0.25, 0.5)
@export var COLOR_PLACED = Color(1.0, 1.0, 1.0, 1.0)

var scene: Sprite2D
var is_valid = false
var is_placed = false

const POSITION_STEP = 128

func _ready() -> void:
	scene = packed_scene.instantiate()
	scene.modulate = COLOR_INVALID
	add_child(scene)

func _process(_delta: float) -> void:
	return

func _unhandled_input(event):
	if !is_placed && event is InputEventMouseMotion:
		var mouse_pos = get_viewport().get_mouse_position()
		var world_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
		var x = int(world_pos.x)
		var y = int(world_pos.y)
		x -= (x % POSITION_STEP) - (POSITION_STEP / 2)
		y -= (y % POSITION_STEP) - (POSITION_STEP / 2)
		scene.global_position = Vector2(x, y)
	
	if is_valid && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		scene.modulate = COLOR_PLACED
		is_placed = true

func _on_platform_area_entered() -> void:
	if is_placed:
		return

	is_valid = true
	scene.modulate = COLOR_VALID

func _on_platform_area_exited() -> void:
	if is_placed:
		return

	is_valid = false
	scene.modulate = COLOR_INVALID
