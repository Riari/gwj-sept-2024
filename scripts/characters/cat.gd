extends CharacterBody2D

@export_group("State")
@export var state_change_interval = [2.0, 5.0]

@export_group("Meows")
@export var meows: Array[AudioStream]
@export var meow_interval = [5.0, 10.0]
@export var meow_particles_duration = 1.0

@export_group("Jumping")
@export var jump_test_interval = 2.0
@export var jump_prepare_duration = 0.3
@export var jump_duration = 0.9

@onready var sprite = get_node("AnimatedSprite2D")
@onready var jump_destination: Node2D = get_node("JumpDestination")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var meow_player: AudioStreamPlayer2D = get_node("Meower")
@onready var meow_particles: CPUParticles2D = get_node("MeowParticles")

enum State
{
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
}

const EMERGENT_STATES = [
	State.IDLE,
	State.WALK,
	State.RUN,
]

const NON_TURNING_STATES = [
	State.IDLE,
	State.JUMP,
	State.FALL,
]

const STATE_TO_ANIM = {
	State.IDLE: "Idle",
	State.WALK: "Walk",
	State.RUN: "Run",
	State.JUMP: "Jump",
	State.FALL: "Fall",
}

const GRAVITY = 150.0

const STATE_TO_VELOCITY = {
	State.IDLE: Vector2(0.0, 0.0),
	State.WALK: Vector2(40.0, 0.0),
	State.RUN: Vector2(150.0, 0.0),
	State.JUMP: Vector2(0.0, 0.0),
	State.FALL: Vector2(40.0, GRAVITY),
}

var current_state: State = State.IDLE
var next_state_change_in: float
var state_change_timer = 0.0
var direction = 1.0
var was_on_floor = true
var was_on_wall = false

var jump_test_timer = 0.0
var jump_path: Path2D
var jump_path_follow: PathFollow2D
var jump_timer = 0.0
var jump_started_at: Vector2

var next_meow_in: float
var meow_timer = 0.0
var meow_particles_timer = 0.0

var rng = RandomNumberGenerator.new()

# TODO: This could probably just be a bool
var valid_jump_destinations = 0

var jump_path_manager: JumpPathManager
var scene: Node

func _ready() -> void:
	scene = get_tree().current_scene
	jump_path_manager = scene.get_node("JumpPathManager")
	assert(jump_path_manager != null, "There's no JumpPathManager in the scene!")

	pick_next_state_change_interval()
	pick_next_meow_interval()

func _process(delta: float) -> void:
	if meow_particles.emitting:
		meow_particles_timer += delta
		if meow_particles_timer >= meow_particles_duration:
			meow_particles.emitting = false
			meow_particles_timer = 0.0

	if current_state == State.JUMP:
		if jump_timer <= jump_duration:
			jump_timer += delta
			if jump_timer > jump_prepare_duration:
				collision_shape.disabled = true
				jump_path_follow.progress_ratio = lerp(0.0, 1.0, (jump_timer - jump_prepare_duration) / (jump_duration - jump_prepare_duration))
				var jump_position = jump_path.curve.sample_baked(jump_path_follow.progress, true)
				if direction < 0.0:
					jump_position.x = -jump_position.x

				global_position = jump_started_at + jump_position
		else:
			collision_shape.disabled = false
			execute_random_state()
		return

	if !was_on_floor && is_on_floor():
		execute_random_state()
		was_on_floor = true
	elif was_on_floor && !is_on_floor():
		execute_state(State.FALL)
		was_on_floor = false
	elif was_on_floor && is_on_floor():
		jump_test_timer += delta
		if jump_test_timer >= jump_test_interval && valid_jump_destinations > 0:
			# TODO: Clean this up
			var should_jump = rng.randi_range(0, 2)
			if should_jump == 2: # 1 in 3
				execute_state(State.JUMP)
				jump_path = jump_path_manager.request_path_at(position, direction)
				jump_path_follow = jump_path.get_node("PathFollow2D")
				jump_timer = 0.0
				jump_started_at = global_position

			jump_test_timer = 0.0

		state_change_timer += delta
		if state_change_timer >= next_state_change_in:
			execute_random_state()
			state_change_timer = 0
		
		meow_timer += delta
		if meow_timer >= next_meow_in:
			meow()
			pick_next_meow_interval()
			meow_timer = 0.0

func _physics_process(_delta: float) -> void:
	if !was_on_wall && is_on_wall():
		change_direction()
		was_on_wall = true
	elif was_on_wall && !is_on_wall():
		was_on_wall = false

	# Jumping is controlled by path
	if current_state != State.JUMP:
		move_and_slide()

func meow() -> void:
	var meow_audio = meows.pick_random()
	meow_player.stream = meow_audio
	meow_player.play()
	meow_particles.emitting = true

func change_direction() -> void:
	scale.x = -scale.x
	direction = -direction
	apply_velocity()

func apply_velocity() -> void:
	var new_velocity = STATE_TO_VELOCITY[current_state]
	velocity = Vector2(new_velocity.x * direction, new_velocity.y)

func execute_state(state: State) -> void:
	current_state = state
	sprite.play(STATE_TO_ANIM[current_state])

	if current_state not in NON_TURNING_STATES:
		var should_change_direction = rng.randi_range(0, 1)
		if should_change_direction == 1:
			change_direction()

	apply_velocity()

func pick_next_state() -> State:
	var new_state = EMERGENT_STATES.pick_random()
	if new_state == current_state:
		return pick_next_state()
	else:
		return new_state

func execute_random_state() -> void:
	execute_state(pick_next_state())
	pick_next_state_change_interval()

func pick_next_state_change_interval() -> void:
	next_state_change_in = rng.randf_range(state_change_interval[0], state_change_interval[1])

func pick_next_meow_interval() -> void:
	next_meow_in = rng.randf_range(meow_interval[0], meow_interval[1])

func on_jump_destination_entered_valid_area() -> void:
	valid_jump_destinations += 1

func on_jump_destination_exited_valid_area() -> void:
	valid_jump_destinations -= 1