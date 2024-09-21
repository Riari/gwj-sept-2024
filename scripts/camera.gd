extends Camera2D

signal player_has_panned_camera

@export var min_zoom = Vector2(0.5, 0.5)
@export var max_zoom = Vector2(1.0, 1.0)
@export var min_pan = Vector2(-1024, -12408)
@export var max_pan = Vector2(1024, 384)
@export var key_pan_step = 10.0
@export var zoom_step = 0.1
@export var zoom_time = 0.1

var is_dragging = false
var drag_mouse_start: Vector2
var drag_camera_start: Vector2

var has_panned_left = false
var has_panned_right = false
var has_panned_up = false
var has_panned_down = false
var has_panned_in_all_directions = false

var locked_node: Node2D = null
var locked_node_offset := Vector2(200, 0)

var zoom_from: Vector2
var zoom_to: Vector2
var zoom_timer = 0.0

const ZOOM_IN = 1.0
const ZOOM_OUT = -1.0

func _ready() -> void:
	zoom_from = zoom
	zoom_to = zoom

func _process(delta: float) -> void:
	if !has_panned_in_all_directions && has_panned_left && has_panned_right && has_panned_down && has_panned_up:
		player_has_panned_camera.emit()
		has_panned_in_all_directions = true
		is_dragging = false

	if locked_node != null:
		position = locked_node.position + locked_node_offset

	if Input.is_action_pressed("pan_left"):
		has_panned_left = true
		position.x -= key_pan_step
		locked_node = null
	if Input.is_action_pressed("pan_right"):
		has_panned_right = true
		position.x += key_pan_step
		locked_node = null
	if Input.is_action_pressed("pan_up"):
		has_panned_up = true
		position.y -= key_pan_step
		locked_node = null
	if Input.is_action_pressed("pan_down"):
		has_panned_down = true
		position.y += key_pan_step
		locked_node = null
	if Input.is_action_pressed("zoom_in"):
		apply_zoom(ZOOM_IN)
	if Input.is_action_pressed("zoom_out"):
		apply_zoom(ZOOM_OUT)

	position = position.clamp(min_pan, max_pan)

	if (zoom_timer >= zoom_time):
		return

	zoom_timer += delta
	zoom = lerp(zoom_from, zoom_to, zoom_timer / zoom_time)
	zoom = zoom.clamp(min_zoom, max_zoom)

func apply_zoom(factor: float = 1.0) -> void:
	zoom_from = zoom
	zoom_to += Vector2(zoom_step * factor, zoom_step * factor)
	zoom_to = zoom_to.clamp(min_zoom, max_zoom)
	zoom_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				apply_zoom(ZOOM_IN)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				apply_zoom(ZOOM_OUT)
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if !is_dragging:
					drag_mouse_start = event.position
					drag_camera_start = position
				is_dragging = true
		else:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				is_dragging = false

	if event is InputEventMouseMotion && is_dragging:
		locked_node = null
		var new_position = (drag_mouse_start - event.position) + drag_camera_start
		if new_position.x > position.x: has_panned_right = true
		if new_position.x < position.x: has_panned_left = true
		if new_position.y < position.y: has_panned_up = true
		if new_position.y > position.y: has_panned_down = true
		position = new_position

func _on_cat_manager_cat_selected(cat: Cat) -> void:
	locked_node = cat
