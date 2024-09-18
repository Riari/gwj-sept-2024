@tool
@icon("res://textures/godot/node-icon--grid.svg")
class_name Grid2D
extends Node2D

@export var grid_width = 8
@export var grid_height = 24
@export var cell_size = 128
@export var margin = 8
@export var enable_ingame_preview = true
@export var cell_preview_air_color = Color(0.3, 0.3, 0.3, 0.5)
@export var cell_preview_available_color = Color(0.0, 0.2, 0.6, 0.35)
@export var cell_preview_full_color = Color(1.0, 0.0, 0.2, 0.35)
@export var cell_preview_hover_color = Color(0.0, 1.0, 0.2, 0.35)

enum CellState
{
	AIR, # Empty space - nothing can be placed here
	SURFACE, # Ground or tower surface - a tower and/or item can be placed here
	TOWER, # Tower - an item can be placed here, but not additional towers
	ITEM, # Item - a tower can be placed here, but not additional items
	TOWER_ITEM, # Tower and item - fully occupied cell, nothing can be placed here
}

const VALID_TOWER_BASE_CELLS = [
	CellState.SURFACE,
	CellState.ITEM,
]

const VALID_ITEM_CELLS = [
	CellState.SURFACE,
	CellState.TOWER,
]

var grid = []
var half_grid_width: int
var half_cell_size = cell_size / 2
var prev_hovered_cell_coords = Vector2i(-2, -2)
var current_hovered_cell_coords = Vector2i(-1, -1)
var can_accept_tower_at_hovered_cell_coords = false
var can_accept_item_at_hovered_cell_coords = false

const INVALID_CELL_COORDS = Vector2i(-1, 1)

func _ready() -> void:
	for y in grid_height:
		grid.push_back([])
		for x in grid_width:
			grid[y].push_back(CellState.SURFACE if y == 0 else CellState.AIR)

func _process(_delta: float) -> void:
	half_grid_width = (grid_width * cell_size) / 2

	prev_hovered_cell_coords = current_hovered_cell_coords
	current_hovered_cell_coords = get_hovered_cell_coords()

	if !enable_ingame_preview && !Engine.is_editor_hint():
		return

	queue_redraw()

func get_cell_draw_color(coords: Vector2i) -> Color:
	if Engine.is_editor_hint():
		return cell_preview_air_color
	
	if current_hovered_cell_coords.x == coords.x && current_hovered_cell_coords.y == coords.y:
		return cell_preview_hover_color

	var cell_state = get_cell_state(coords)
	if cell_state == CellState.TOWER_ITEM:
		return cell_preview_full_color
	
	if cell_state == CellState.AIR:
		return cell_preview_air_color

	return cell_preview_available_color

func _draw():
	if !enable_ingame_preview && !Engine.is_editor_hint():
		return

	for x in grid_width:
		for y in grid_height:
			var start_at = Vector2(x * cell_size + margin - half_grid_width, -y * cell_size - margin)
			var end_at = Vector2(cell_size - margin, -cell_size + margin)
			var color = get_cell_draw_color(Vector2i(x, -y))
			draw_rect(Rect2(start_at, end_at), color)

func get_cell_state(coords: Vector2i) -> CellState:
	return grid[coords.y][coords.x]

func get_hovered_cell_coords() -> Vector2i:
	var relative_mouse_pos = get_global_mouse_position() - Vector2(global_position.x - half_grid_width, global_position.y)
	if relative_mouse_pos.x < 0 || relative_mouse_pos.x > grid_width * cell_size:
		return INVALID_CELL_COORDS
	
	if relative_mouse_pos.y > 0 || relative_mouse_pos.y < -(grid_height * cell_size):
		return INVALID_CELL_COORDS

	var coords = Vector2i(int(relative_mouse_pos.x / cell_size), int(relative_mouse_pos.y / cell_size))
	return coords

func get_hovered_cell_position() -> Vector2:
	var coords = current_hovered_cell_coords
	if coords.x == -1 && coords.y == 1:
		return Vector2(-1, -1)

	return Vector2(coords.x * cell_size + half_cell_size, coords.y * cell_size - half_cell_size)

func can_accept_tower_at_hovered_cell(cells: Array) -> bool:
	if current_hovered_cell_coords == INVALID_CELL_COORDS:
		return false

	if current_hovered_cell_coords == prev_hovered_cell_coords:
		return can_accept_tower_at_hovered_cell_coords

	var origin_coords = current_hovered_cell_coords
	if origin_coords.x == -1 && origin_coords.y == 1:
		return false

	var base_y = origin_coords.y
	var surface_y = origin_coords.y - 1

	if surface_y < -grid_height:
		return false

	for relative_x in cells:
		var x = origin_coords.x + relative_x
		if x < 0 || x > grid_width - 1:
			return false

		var base_cell_state = get_cell_state(Vector2i(x, base_y))
		if relative_x == 0 && !VALID_TOWER_BASE_CELLS.has(base_cell_state):
			can_accept_tower_at_hovered_cell_coords = false
			return false

		var surface_cell_state = get_cell_state(Vector2i(x, surface_y))
		if surface_cell_state != CellState.AIR:
			can_accept_tower_at_hovered_cell_coords = false
			return false

	can_accept_tower_at_hovered_cell_coords = true
	return true

func place_tower_at_hovered_cell(cells: Array):
	if !can_accept_tower_at_hovered_cell_coords:
		return

	var origin_coords = current_hovered_cell_coords
	var base_y = origin_coords.y
	var surface_y = origin_coords.y - 1
	
	for relative_x in cells:
		var x = origin_coords.x + relative_x
		grid[base_y][x] = CellState.TOWER
		grid[surface_y][x] = CellState.SURFACE

func can_accept_item_at_hovered_cell() -> bool:
	if current_hovered_cell_coords == INVALID_CELL_COORDS:
		return false

	if current_hovered_cell_coords == prev_hovered_cell_coords:
		return can_accept_item_at_hovered_cell_coords

	var coords = current_hovered_cell_coords
	if coords.x == -1 && coords.y == 1:
		can_accept_item_at_hovered_cell_coords = false
		return false

	if coords.y == 0:
		# Items can't be placed on the ground
		can_accept_item_at_hovered_cell_coords = false
		return false

	var cell_state = get_cell_state(coords)
	var result = VALID_ITEM_CELLS.has(cell_state)
	can_accept_item_at_hovered_cell_coords = result
	return result