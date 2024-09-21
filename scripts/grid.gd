@tool
@icon("res://textures/godot/node-icon--grid.svg")
class_name Grid2D
extends Node2D

@export var grid_width = 8
@export var grid_height = 24
@export var cell_size = 128
@export var margin = 8
@export var cell_preview_air_color = Color(1.0, 1.0, 1.0, 0.1)
@export var cell_preview_available_color = Color(0.0, 0.6, 0.2, 0.45)
@export var cell_preview_unavailable_color = Color(1.0, 0.0, 0.2, 0.45)
@export var cell_preview_hover_color = Color(1.0, 1.0, 1.0, 0.2)

enum PlaceMode
{
	NONE, # The player is not placing anything
	TOWER, # The player is placing a tower segment
	ITEM, # The player is placing an item
}

enum CellState
{
	AIR,
	TOWER,
	EMPTY_SURFACE,
	SURFACE_WITH_TOWER,
	SURFACE_WITH_ITEM,
	FULL_SURFACE,
}

const VALID_CELLS_FOR_TOWER_BASE = [
	CellState.EMPTY_SURFACE,
	CellState.SURFACE_WITH_ITEM,
]

const VALID_CELLS_FOR_TOWER_SURFACE = [
	CellState.AIR,
	CellState.TOWER,
]

const VALID_CELLS_FOR_ITEMS = [
	CellState.EMPTY_SURFACE,
	CellState.SURFACE_WITH_TOWER,
]

const INVALID_CELL_COORDS = Vector2i(-1, -1)

var grid = []
var current_place_mode := PlaceMode.NONE
var preview_ground_placement = true
var half_cell_size = cell_size / 2
var previous_hovered_cell_coords: Vector2i
var current_hovered_cell_coords = INVALID_CELL_COORDS

func _ready() -> void:
	for y in grid_height:
		grid.push_back([])
		for x in grid_width:
			grid[y].push_back(CellState.EMPTY_SURFACE if y == 0 else CellState.AIR)

func _process(_delta: float) -> void:
	if current_place_mode != PlaceMode.NONE || Engine.is_editor_hint():
		previous_hovered_cell_coords = current_hovered_cell_coords
		current_hovered_cell_coords = get_hovered_cell_coords()
		if previous_hovered_cell_coords != current_hovered_cell_coords:
			queue_redraw()

	if Engine.is_editor_hint():
		queue_redraw()

func enable_preview(place_mode: PlaceMode) -> void:
	current_place_mode = place_mode
	preview_ground_placement = place_mode == PlaceMode.TOWER
	queue_redraw()

func disable_preview() -> void:
	current_place_mode = PlaceMode.NONE
	preview_ground_placement = false
	queue_redraw()

func get_cell_draw_color(coords: Vector2i) -> Color:
	if Engine.is_editor_hint():
		return cell_preview_air_color

	if current_place_mode == PlaceMode.NONE:
		return cell_preview_air_color

	var cell_state = get_cell_state(coords)
	if cell_state == CellState.AIR:
		return cell_preview_air_color

	if cell_state == CellState.FULL_SURFACE:
		return cell_preview_unavailable_color

	if cell_state == CellState.SURFACE_WITH_ITEM && current_place_mode == PlaceMode.ITEM:
		return cell_preview_unavailable_color

	if cell_state == CellState.SURFACE_WITH_TOWER && current_place_mode == PlaceMode.TOWER:
		return cell_preview_unavailable_color

	return cell_preview_available_color

func _draw():
	if current_place_mode == PlaceMode.NONE && !Engine.is_editor_hint():
		return

	for x in grid_width:
		for y in grid_height:
			var color = cell_preview_unavailable_color if y == 0 && !preview_ground_placement else get_cell_draw_color(Vector2i(x, y))
			draw_cell(x, y, color)

			if current_hovered_cell_coords == Vector2i(x, y):
				draw_cell(x, y, cell_preview_hover_color)

func draw_cell(x: int, y: int, color: Color):
	var start_at = Vector2(x * cell_size + margin, -y * cell_size - margin)
	var end_at = Vector2(cell_size - margin * 2, -cell_size + margin * 2)
	draw_rect(Rect2(start_at, end_at), color)

func get_cell_state(coords: Vector2i) -> CellState:
	return grid[coords.y][coords.x]

func get_cell_coords_at(input_position: Vector2) -> Vector2i:
	var relative_pos = input_position - Vector2(global_position.x, global_position.y)
	if relative_pos.x < 0 || relative_pos.x > grid_width * cell_size:
		return INVALID_CELL_COORDS
	
	if relative_pos.y > 0 || relative_pos.y < -(grid_height * cell_size):
		return INVALID_CELL_COORDS

	var coords = Vector2i(int(relative_pos.x / cell_size), -int(relative_pos.y / cell_size))
	return coords

func get_hovered_cell_coords() -> Vector2i:
	return get_cell_coords_at(get_global_mouse_position())

func get_hovered_cell_position() -> Vector2:
	var cell_coords = get_hovered_cell_coords()
	if cell_coords == INVALID_CELL_COORDS:
		return Vector2(-1, -1)

	var relative_position = Vector2(cell_coords.x * cell_size + half_cell_size, -cell_coords.y * cell_size - half_cell_size)

	return relative_position + global_position

func can_place_tower_at_cell(cell_coords: Vector2i, layout: Array) -> bool:
	if cell_coords == INVALID_CELL_COORDS:
		return false

	var base_y = cell_coords.y
	var surface_y = cell_coords.y + 1

	if surface_y >= grid_height:
		return false

	for x_offset in layout:
		var x = cell_coords.x + x_offset
		if x < 0 || x >= grid_width:
			return false

		var cell_state_base = grid[base_y][x]
		var valid_for_tower_base = VALID_CELLS_FOR_TOWER_BASE.has(cell_state_base)
		if (x_offset == 0 || cell_state_base != CellState.AIR) && !valid_for_tower_base:
			# Checks for valid cells as follows:
			# Tower base: VALID_CELLS_FOR_TOWER_BASE
			# Overhang: AIR or VALID_CELLS_FOR_TOWER_BASE
			return false

		var cell_state_surface = grid[surface_y][x]
		if !VALID_CELLS_FOR_TOWER_SURFACE.has(cell_state_surface):
			return false
	
	return true

func can_place_tower_at_hovered_cell(layout: Array) -> bool:
	var cell_coords = get_hovered_cell_coords()
	return can_place_tower_at_cell(cell_coords, layout)

func place_tower_at_cell(cell_coords: Vector2i, layout: Array) -> void:
	var base_y = cell_coords.y
	var surface_y = cell_coords.y + 1
	for offset_x in layout:
		var x = cell_coords.x + offset_x
		match grid[base_y][x]:
			CellState.AIR: grid[base_y][x] = CellState.TOWER
			CellState.EMPTY_SURFACE: grid[base_y][x] = CellState.SURFACE_WITH_TOWER
			CellState.SURFACE_WITH_ITEM: grid[base_y][x] = CellState.FULL_SURFACE

		grid[surface_y][x] = CellState.EMPTY_SURFACE

func place_tower_at_hovered_cell(layout: Array) -> void:
	var cell_coords = get_hovered_cell_coords()
	place_tower_at_cell(cell_coords, layout)

func can_place_item_at_cell(cell_coords: Vector2i) -> bool:
	if cell_coords == INVALID_CELL_COORDS || cell_coords.y == 0:
		return false
	
	var cell_state = grid[cell_coords.y][cell_coords.x]
	return VALID_CELLS_FOR_ITEMS.has(cell_state)

func can_place_item_at_hovered_cell() -> bool:
	var cell_coords = get_hovered_cell_coords()
	return can_place_item_at_cell(cell_coords)

func place_item_at_cell(cell_coords: Vector2i) -> void:
	grid[cell_coords.y][cell_coords.x] = CellState.FULL_SURFACE if grid[cell_coords.y][cell_coords.x] == CellState.SURFACE_WITH_TOWER else CellState.SURFACE_WITH_ITEM

func place_item_at_hovered_cell() -> void:
	var cell_coords = get_hovered_cell_coords()
	place_item_at_cell(cell_coords)
