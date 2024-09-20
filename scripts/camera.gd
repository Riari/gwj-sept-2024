extends Camera2D

@export var min_zoom = Vector2(0.5, 0.5)
@export var max_zoom = Vector2(1.0, 1.0)
@export var min_pan = Vector2(-1024, -12408)
@export var max_pan = Vector2(1024, 384)
@export var key_pan_step = 10.0
@export var zoom_step = 0.1
@export var zoom_time = 0.1

var is_dragging = false
var scroll_mouse_start: Vector2
var scroll_camera_start: Vector2

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
	if locked_node != null:
		position = locked_node.position + locked_node_offset

	if Input.is_action_pressed("pan_left"):
		position.x -= key_pan_step
		locked_node = null
	if Input.is_action_pressed("pan_right"):
		position.x += key_pan_step
		locked_node = null
	if Input.is_action_pressed("pan_up"):
		position.y -= key_pan_step
		locked_node = null
	if Input.is_action_pressed("pan_down"):
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
					scroll_mouse_start = event.position
					scroll_camera_start = position
				is_dragging = true
		else:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				is_dragging = false

	if event is InputEventMouseMotion && is_dragging:
		locked_node = null
		position = (scroll_mouse_start - event.position) + scroll_camera_start

func _on_cat_manager_cat_selected(cat: Cat) -> void:
	locked_node = cat
