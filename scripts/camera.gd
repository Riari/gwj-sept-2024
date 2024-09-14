extends Camera2D

@export var min_zoom = Vector2(0.5, 0.5)
@export var max_zoom = Vector2(1.5, 1.5)
@export var zoom_step = 0.1

var is_dragging = false
var scroll_mouse_start: Vector2
var scroll_camera_start: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP: # zoom in
				zoom.x += zoom_step
				zoom.y += zoom_step
				zoom.x = min(max_zoom.x, zoom.x)
				zoom.y = min(max_zoom.y, zoom.y)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: # zoom out
				zoom.x -= zoom_step
				zoom.y -= zoom_step
				zoom.x = max(min_zoom.x, zoom.x)
				zoom.y = max(min_zoom.y, zoom.y)
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