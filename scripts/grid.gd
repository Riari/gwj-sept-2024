@tool
extends Node2D

@export var grid_width = 8
@export var grid_height = 24
@export var cell_size = 128
@export var margin = 4
@export var cell_preview_color = Color(1.0, 0.0, 0.2, 0.35)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		var half_grid_width = (grid_width * cell_size) / 2
		for x in grid_width:
			for y in grid_height:
				var start_at = Vector2(x * cell_size + margin - half_grid_width, -y * cell_size - margin)
				var end_at = Vector2(cell_size - margin, -cell_size + margin)
				draw_rect(Rect2(start_at, end_at), cell_preview_color)