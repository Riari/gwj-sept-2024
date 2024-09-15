@tool
extends Node2D

@export var grid_offset = Vector2(64, 0)
@export var grid_width = 8
@export var grid_height = 24
@export var cell_size = 128
@export var margin = 4
@export var cell_preview_color = Color(1.0, 0.0, 0.2, 0.35)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		for x in grid_width:
			for y in grid_height:
				var start_at = Vector2(x * cell_size + grid_offset.x + margin, -y * cell_size - grid_offset.y - margin)
				var end_at = Vector2(cell_size - margin, -cell_size + margin)
				draw_rect(Rect2(start_at, end_at), cell_preview_color)