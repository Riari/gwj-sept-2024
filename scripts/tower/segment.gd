class_name TowerSegment
extends Node2D

signal platform_area_entered
signal platform_area_exited

@export var area_jump_destination = "JumpDestination"
@export var place_down_particles_duration = 0.2

@onready var platform: NinePatchSprite2D = $Platform
@onready var platform_surface_area: Area2D = $PlatformSurfaceArea
@onready var platform_surface_area_shape: CollisionShape2D = $PlatformSurfaceArea/Shape
@onready var platform_area: StaticBody2D = $PlatformArea
@onready var platform_area_shape: CollisionShape2D = $PlatformArea/Shape
@onready var place_down_particles: CPUParticles2D = $PlaceDownParticles
@onready var place_down_audio: AudioStreamPlayer2D = $PlaceDownAudio

var place_down_particles_timer = 0.0

const PLATFORM_SURFACE_AREA_HEIGHT = 128

func configure( platform_width: float, platform_offset: float) -> void:
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

func on_place() -> void:
	place_down_particles.emitting = true
	place_down_audio.play()

func _process(delta: float) -> void:
	if place_down_particles.emitting:
		place_down_particles_timer += delta
		if place_down_particles_timer > place_down_particles_duration:
			place_down_particles.emitting = false

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

func disable_areas():
	platform_surface_area.process_mode = Node.PROCESS_MODE_DISABLED
	platform_area.process_mode = Node.PROCESS_MODE_DISABLED

func enable_areas():
	platform_surface_area.process_mode = Node.PROCESS_MODE_INHERIT
	platform_area.process_mode = Node.PROCESS_MODE_INHERIT
