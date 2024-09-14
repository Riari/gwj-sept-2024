extends Camera2D

@export var min_zoom = Vector2(0.5, 0.5)
@export var max_zoom = Vector2(1.5, 1.5)
@export var zoom_step = 0.1
@export var zoom_time = 0.1

var is_dragging = false
var scroll_mouse_start: Vector2
var scroll_camera_start: Vector2

var zoom_from: Vector2
var zoom_to: Vector2
var zoom_timer = 0.0

const ZOOM_IN = 1.0
const ZOOM_OUT = -1.0

func _process(delta: float) -> void:
	if (zoom_timer >= zoom_time):
		return

	zoom_timer += delta
	zoom = lerp(zoom_from, zoom_to, zoom_timer / zoom_time)

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
		position = zoom * (scroll_mouse_start - event.position) + scroll_camera_start
		position.x = clamp(position.x, limit_left, limit_right)
		position.y = clamp(position.y, limit_top, limit_bottom)