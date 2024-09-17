extends Node2D

signal platform_area_entered
signal platform_area_exited

@export var area_jump_destination = "JumpDestination"
@export var platform_width = 256.0
@export var platform_offset = 0.0

@onready var platform: NinePatchSprite2D = $Platform
@onready var platform_surface_area: Area2D = $PlatformSurfaceArea
@onready var platform_surface_area_shape: CollisionShape2D = $PlatformSurfaceArea/Shape
@onready var platform_area: StaticBody2D = $PlatformArea
@onready var platform_area_shape: CollisionShape2D = $PlatformArea/Shape

const PLATFORM_SURFACE_AREA_HEIGHT = 128

func _ready() -> void:
	if platform_offset != 0.0:
		platform.position.x += platform_offset
		platform_surface_area.position.x += platform_offset
		platform_area.position.x += platform_offset

	platform.size.x = platform_width

	var platform_surface_area_rect = RectangleShape2D.new()
	platform_surface_area_rect.extents = Vector2(platform_width / 2, PLATFORM_SURFACE_AREA_HEIGHT / 2)
	platform_surface_area_shape.shape = platform_surface_area_rect

	var platform_area_rect = RectangleShape2D.new()
	platform_area_rect.extents = Vector2(platform_width / 2, platform.size.y / 2)
	platform_area_shape.shape = platform_area_rect

func _on_mouse_entered() -> void:
	platform_area_entered.emit()

func _on_mouse_exited() -> void:
	platform_area_exited.emit()

func _on_platform_surface_area_body_entered(_body: Node2D) -> void:
	pass

func _on_platform_surface_area_body_exited(_body: Node2D) -> void:
	pass

func _on_platform_surface_area_area_entered(area: Area2D) -> void:
	if area.name == area_jump_destination:
		area.get_parent().call("on_jump_destination_entered_valid_area")

func _on_platform_surface_area_area_exited(area: Area2D) -> void:
	if area.name == area_jump_destination:
		area.get_parent().call("on_jump_destination_exited_valid_area")
