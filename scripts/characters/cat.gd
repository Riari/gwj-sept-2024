class_name Cat
extends CharacterBody2D

signal interaction_complete(cat: Cat, item: Item)
signal selected(cat: Cat)

@export_group("State")
@export var state_change_interval = [2.0, 5.0]
@export var change_direction_percentage_chance = 50.0

@export_group("Audio")
@export var meows: Array[AudioStream]
@export var purrs: Array[AudioStream]
@export var sound_interval = [3.0, 10.0]
@export var sound_particles_duration = 1.0

@export_group("Jumping")
@export var jump_test_interval = 3.0
@export var jump_up_percentage_chance = 60.0
@export var jump_up_prepare_duration = 0.3
@export var jump_up_duration = 0.9
@export var jump_down_percentage_chance = 40.0
@export var jump_down_duration = 0.5

@export_group("Interactions")
@export var interaction_percentage_chance = 50.0
@export var interaction_interval_fuzzing = 3.0

@onready var sprite = $AnimatedSprite2D
@onready var jump_destination: Node2D = $JumpDestination
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var sound_particles: CPUParticles2D = $SoundParticles

# TODO: Refactor states to be handled more uniformly and use weighted picking for pseudo-random state selection

enum State
{
	IDLE,
	WALK,
	RUN,
	JUMP_UP,
	JUMP_DOWN,
	FALL,
	LOAF,
	PLAY,
	EAT,
	DRINK,
}

const EMERGENT_STATES = [
	State.IDLE,
	State.WALK,
	State.RUN,
]

const NON_TURNING_STATES = [
	State.IDLE,
	State.JUMP_UP,
	State.FALL,
]

const INTERACTION_STATES = [
	State.LOAF,
	State.PLAY,
	State.EAT,
	State.DRINK,
]

const STATE_TO_ANIM = {
	State.IDLE: "Idle",
	State.WALK: "Walk",
	State.RUN: "Run",
	State.JUMP_UP: "Jump",
	State.JUMP_DOWN: "Fall",
	State.FALL: "Fall",
	State.LOAF: "Loaf",
	State.PLAY: "Play",
	State.EAT: "Eat",
	State.DRINK: "Eat",
}

const STATE_TO_ACTIVITY = {
	State.IDLE: "Idle",
	State.WALK: "Exploring",
	State.RUN: "Exploring",
	State.JUMP_UP: "Exploring",
	State.JUMP_DOWN: "Exploring",
	State.FALL: "Exploring",
	State.LOAF: "Napping",
	State.PLAY: "Playing",
	State.EAT: "Eating",
	State.DRINK: "Drinking",
}

const GRAVITY = 200.0

const ZERO_VELOCITY = Vector2(0.0, 0.0)

const STATE_TO_VELOCITY = {
	State.WALK: Vector2(40.0, 0.0),
	State.RUN: Vector2(150.0, 0.0),
	State.FALL: Vector2(40.0, GRAVITY),
	State.JUMP_DOWN: Vector2(40.0, GRAVITY),
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

var scene: Node
var jump_path_manager: JumpPathManager
var grid: Grid2D

var current_tower_level = 0

var in_freshly_spawned_mode = true

var cat_name = ""
var cat_description = ""
var cat_profile_image: Texture2D

var open_window: CatWindow = null

func configure(_name: String, _description: String, _meows: Array, _purrs: Array) -> void:
	cat_name = _name
	cat_description = _description
	meows = _meows
	purrs = _purrs

func _ready() -> void:
	scene = get_tree().current_scene
	jump_path_manager = scene.get_node("JumpPathManager")
	assert(jump_path_manager != null, "There's no JumpPathManager in the scene!")

	grid = scene.get_node("Grid")
	assert(grid != null, "There's no Grid2D in the scene!")

	execute_state(State.RUN, false)
	direction = RIGHT
	velocity.y = GRAVITY

	pick_next_state_change_interval()
	pick_next_sound_interval()

	cat_profile_image = sprite.get_sprite_frames().get_frame_texture("Idle", 0)

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
			finish_interacting()

		sound_timer += delta
		if sound_timer >= next_sound_in:
			if current_state == State.PLAY: meow()
			else: purr()
			pick_next_sound_interval()
			sound_timer = 0.0

		return

	if current_state == State.JUMP_UP:
		if jump_timer <= jump_up_duration:
			jump_timer += delta
			if jump_timer > jump_up_prepare_duration:
				collision_shape.disabled = true
				jump_path_follow.progress_ratio = lerp(0.0, 1.0, (jump_timer - jump_up_prepare_duration) / (jump_up_duration - jump_up_prepare_duration))
				var jump_position = jump_path.curve.sample_baked(jump_path_follow.progress, true)
				if direction < 0.0:
					jump_position.x = -jump_position.x

				global_position = jump_started_at + jump_position
		else:
			collision_shape.disabled = false
			update_current_tower_level()
			execute_random_state()
		return
	
	if current_state == State.JUMP_DOWN:
		if jump_timer <= jump_down_duration:
			jump_timer += delta
		else:
			collision_shape.disabled = false
			update_current_tower_level()
			execute_state(State.FALL)
		return

	if !was_on_floor && is_on_floor():
		update_current_tower_level()
		execute_random_state()
		was_on_floor = true
	elif was_on_floor && !is_on_floor():
		execute_state(State.FALL)
		was_on_floor = false
	elif was_on_floor && is_on_floor():
		jump_test_timer += delta
		if jump_test_timer >= jump_test_interval && valid_jump_destinations > 0:
			rng.randomize()
			var jump_up_factor = rng.randf_range(0, 100)
			var jump_down_factor = rng.randf_range(0, 100)
			var should_jump_up = jump_up_factor < jump_up_percentage_chance
			var should_jump_down = current_tower_level < 0 && jump_down_factor < jump_down_percentage_chance
			if should_jump_up && should_jump_down:
				if should_jump_up > should_jump_down:
					initiate_jump_up()
				else:
					initiate_jump_down()
			elif should_jump_up:
				initiate_jump_up()
			elif should_jump_down:
				initiate_jump_down()

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

	# Jumping up is controlled by path
	if current_state != State.JUMP_UP:
		move_and_slide()

func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_point)

func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(mouse_default)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_released("select"):
		selected.emit(self)

func on_window_closed() -> void:
	open_window = null

func finish_interacting() -> void:
	interaction_complete.emit(self, current_interaction_node)
	current_interaction_node.on_finished_using()
	get_parent().move_child(self, -1)
	execute_random_state()

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

func initiate_jump_up() -> void:
	execute_state(State.JUMP_UP)
	jump_path = jump_path_manager.request_path_at(position, direction)
	jump_path_follow = jump_path.get_node("PathFollow2D")
	jump_timer = 0.0
	jump_started_at = global_position

func initiate_jump_down() -> void:
	execute_state(State.JUMP_DOWN)
	collision_shape.disabled = true
	jump_timer = 0.0

func update_current_tower_level() -> void:
	current_tower_level = grid.get_cell_coords_at(global_position).y
	print("%s is now on tower level %d" % [cat_name, current_tower_level])

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

	if open_window != null:
		open_window.set_activity(STATE_TO_ACTIVITY[state])

	sprite.play(STATE_TO_ANIM[current_state])

	if allow_direction_change && current_state not in NON_TURNING_STATES:
		rng.randomize()
		var change_direction_factor = rng.randf_range(0, 100)
		if change_direction_factor < change_direction_percentage_chance:
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
	rng.randomize()
	next_state_change_in = rng.randf_range(state_change_interval[0], state_change_interval[1])

func pick_next_sound_interval() -> void:
	rng.randomize()
	next_sound_in = rng.randf_range(sound_interval[0], sound_interval[1])

func on_jump_destination_entered_valid_area() -> void:
	valid_jump_destinations += 1

func on_jump_destination_exited_valid_area() -> void:
	valid_jump_destinations -= 1

func start_interaction(item: Node2D, state: State, interaction_position: Vector2) -> void:
	rng.randomize()
	execute_state(state)
	global_position = interaction_position
	var min_interval = item.item_data["InteractionInterval"][0]
	var max_interval = item.item_data["InteractionInterval"][1]
	var interaction_interval = [
		rng.randf_range(min_interval - interaction_interval_fuzzing, min_interval + interaction_interval_fuzzing),
		rng.randf_range(max_interval - interaction_interval_fuzzing, max_interval + interaction_interval_fuzzing)
	]
	interaction_ends_in = rng.randf_range(interaction_interval[0], interaction_interval[1])
	interaction_timer = 0.0
	current_interaction_node = item
	get_parent().move_child(self, 0)

func tempt_action(item: Node2D, state: State, interaction_position: Vector2) -> bool:
	rng.randomize()
	var interact_factor = rng.randf_range(0, 100)
	if interact_factor < interaction_percentage_chance:
		start_interaction(item, state, interaction_position)
		return true
	
	return false

func get_current_activity() -> String:
	return STATE_TO_ACTIVITY[current_state]