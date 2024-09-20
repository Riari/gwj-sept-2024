class_name Cat
extends CharacterBody2D

signal interaction_complete(value: int)
signal selected(cat: Cat)

@export_group("State")
@export var state_change_interval = [2.0, 5.0]

@export_group("Audio")
@export var meows: Array[AudioStream]
@export var purrs: Array[AudioStream]
@export var sound_interval = [3.0, 10.0]
@export var sound_particles_duration = 1.0

@export_group("Jumping")
@export var jump_test_interval = 2.0
@export var jump_prepare_duration = 0.3
@export var jump_duration = 0.9

@export_group("Interactions")
@export var interaction_interval = [7.0, 15.0]

@onready var sprite = $AnimatedSprite2D
@onready var jump_destination: Node2D = $JumpDestination
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var sound_particles: CPUParticles2D = $SoundParticles

enum State
{
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	LOAF,
	PLAY,
	EAT,
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

const INTERACTION_STATES = [
	State.LOAF,
	State.PLAY,
	State.EAT,
]

const STATE_TO_ANIM = {
	State.IDLE: "Idle",
	State.WALK: "Walk",
	State.RUN: "Run",
	State.JUMP: "Jump",
	State.FALL: "Fall",
	State.LOAF: "Loaf",
	State.PLAY: "Play",
	State.EAT: "Eat",
}

const GRAVITY = 200.0

const ZERO_VELOCITY = Vector2(0.0, 0.0)

const STATE_TO_VELOCITY = {
	State.WALK: Vector2(40.0, 0.0),
	State.RUN: Vector2(150.0, 0.0),
	State.FALL: Vector2(40.0, GRAVITY),
}

const RIGHT = 1.0
const LEFT = -1.0

var mouse_default = load("res://textures/cursors/arrow.png")
var mouse_point = load("res://textures/cursors/point.png")

var current_state: State = State.IDLE
var next_state_change_in: float
var state_change_timer = 0.0
var direction = RIGHT
var was_on_floor = true
var was_on_wall = false

var jump_test_timer = 0.0
var jump_path: Path2D
var jump_path_follow: PathFollow2D
var jump_timer = 0.0
var jump_started_at: Vector2

var next_sound_in: float
var sound_timer = 0.0
var sound_particles_timer = 0.0

var interaction_ends_in: float
var interaction_timer = 0.0
var current_interaction_node: Node2D

var rng = RandomNumberGenerator.new()

# TODO: This could probably just be a bool
var valid_jump_destinations = 0

var jump_path_manager: JumpPathManager
var scene: Node

var in_freshly_spawned_mode = true

var cat_name = ""
var cat_description = ""

func configure(_name: String, _description: String, _meows: Array, _purrs: Array) -> void:
	cat_name = _name
	cat_description = _description
	meows = _meows
	purrs = _purrs

func _ready() -> void:
	scene = get_tree().current_scene
	jump_path_manager = scene.get_node("JumpPathManager")
	assert(jump_path_manager != null, "There's no JumpPathManager in the scene!")

	execute_state(State.WALK, false)
	direction = RIGHT
	velocity.y = GRAVITY

	pick_next_state_change_interval()
	pick_next_sound_interval()

func _process(delta: float) -> void:
	if in_freshly_spawned_mode:
		return

	if sound_particles.emitting:
		sound_particles_timer += delta
		if sound_particles_timer >= sound_particles_duration:
			sound_particles.emitting = false
			sound_particles_timer = 0.0
	
	if INTERACTION_STATES.has(current_state):
		interaction_timer += delta
		if interaction_timer >= interaction_ends_in:
			interaction_complete.emit(current_interaction_node.item_data["Earns"])
			current_interaction_node.on_finished_using()
			execute_random_state()

		sound_timer += delta
		if sound_timer >= next_sound_in:
			if current_state == State.PLAY: meow()
			else: purr()
			pick_next_sound_interval()
			sound_timer = 0.0

		return

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

func _physics_process(_delta: float) -> void:
	if !was_on_wall && is_on_wall():
		change_direction()
		was_on_wall = true
	elif was_on_wall && !is_on_wall():
		was_on_wall = false

	# Jumping is controlled by path
	if current_state != State.JUMP:
		move_and_slide()

func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_point)

func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(mouse_default)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_released("select"):
		selected.emit(self)

func disable_freshly_spawned_mode() -> void:
	in_freshly_spawned_mode = false
	set_collision_mask_value(3, true)

func meow() -> void:
	var meow_audio = meows.pick_random()
	audio_player.stream = meow_audio
	audio_player.play()
	sound_particles.emitting = true

func purr() -> void:
	var purr_audio = purrs.pick_random()
	audio_player.stream = purr_audio
	audio_player.play()
	sound_particles.emitting = true

func change_direction() -> void:
	scale.x = -scale.x
	direction = -direction
	apply_velocity()

func face_left() -> void:
	scale.x = LEFT
	direction = LEFT
	apply_velocity()

func face_right() -> void:
	scale.x = RIGHT
	direction = RIGHT
	apply_velocity()

func apply_velocity() -> void:
	var new_velocity = ZERO_VELOCITY if !STATE_TO_VELOCITY.has(current_state) else STATE_TO_VELOCITY[current_state]
	velocity = Vector2(new_velocity.x * direction, new_velocity.y)

func execute_state(state: State, allow_direction_change: bool = true) -> void:
	current_state = state
	sprite.play(STATE_TO_ANIM[current_state])

	if allow_direction_change && current_state not in NON_TURNING_STATES:
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

func pick_next_sound_interval() -> void:
	next_sound_in = rng.randf_range(sound_interval[0], sound_interval[1])

func on_jump_destination_entered_valid_area() -> void:
	valid_jump_destinations += 1

func on_jump_destination_exited_valid_area() -> void:
	valid_jump_destinations -= 1

func start_interaction_timer() -> void:
	interaction_ends_in = rng.randf_range(interaction_interval[0], interaction_interval[1])
	interaction_timer = 0.0

func tempt_action(item: Node2D, state: State, interaction_position: Vector2) -> bool:
	# TODO: make this configurable
	var random = rng.randi_range(0, 1)
	if random == 1:
		execute_state(state)
		global_position = interaction_position
		start_interaction_timer()
		current_interaction_node = item
		return true
	
	return false
