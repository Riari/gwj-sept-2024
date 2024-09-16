extends CharacterBody2D

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

const STATE_TO_ANIM = {
	State.IDLE: "Idle",
	State.WALK: "Walk",
	State.RUN: "Run",
	State.FALL: "Fall",
	State.JUMP: "Jump",
}

const GRAVITY = 150.0

const STATE_TO_VELOCITY = {
	State.IDLE: Vector2(0.0, 0.0),
	State.WALK: Vector2(40.0, 0.0),
	State.RUN: Vector2(150.0, 0.0),
	State.FALL: Vector2(40.0, GRAVITY),
}

var current_state: State = State.IDLE
var state_change_interval = [2.0, 5.0]
var next_state_change_in: float
var state_change_timer = 0.0
var direction = 1.0
var was_on_floor = true

var jump_test_interval = 2.0
var jump_test_timer = 0.0
var jump_path: PathFollow2D
var jump_prepare_duration = 0.3
var jump_duration = 1.0
var jump_timer = 0.0

var rng = RandomNumberGenerator.new()

# TODO: This could probably just be a bool
var valid_jump_destinations = 0

@onready var sprite = get_node("AnimatedSprite2D")
@onready var jump_destination: Node2D = get_node("JumpDestination")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
var jump_path_manager: JumpPathManager
var scene: Node

func _ready() -> void:
	scene = get_tree().current_scene
	jump_path_manager = scene.get_node("JumpPathManager")
	assert(jump_path_manager != null, "There's no JumpPathManager in the scene!")

	pick_next_state_change_interval()

func _process(delta: float) -> void:
	if current_state == State.JUMP:
		if jump_timer <= jump_duration:
			jump_timer += delta
			if jump_timer > jump_prepare_duration:
				jump_path.progress_ratio = lerp(0.0, 1.0, (jump_timer - jump_prepare_duration) / (jump_duration - jump_prepare_duration))
		else:
			reparent(scene, true)
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
				jump_path = jump_path_manager.request_path_at(jump_destination.position, direction)
				sprite.play("Jump")
				velocity = Vector2(0, 0)
				reparent(jump_path, true)
				current_state = State.JUMP
				jump_timer = 0.0
				collision_shape.disabled = true

			jump_test_timer = 0.0

		state_change_timer += delta
		if state_change_timer >= next_state_change_in:
			execute_random_state()
			state_change_timer = 0

func _physics_process(_delta: float) -> void:
	move_and_slide()

func execute_state(state: State) -> void:
	current_state = state

	if current_state not in [State.IDLE, State.FALL]:
		var should_change_direction = rng.randi_range(0, 1)
		if should_change_direction == 1:
			scale.x = -scale.x
			direction = -direction

	sprite.play(STATE_TO_ANIM[current_state])
	var new_velocity = STATE_TO_VELOCITY[current_state]
	velocity = Vector2(new_velocity.x * direction, new_velocity.y)

func pick_next_state() -> State:
	var new_state = EMERGENT_STATES.pick_random()
	if new_state == current_state:
		return pick_next_state()
	else:
		return new_state

func execute_random_state() -> void:
	execute_state(pick_next_state())
	pick_next_state_change_interval()

func pick_next_state_change_interval():
	next_state_change_in = rng.randf_range(state_change_interval[0], state_change_interval[1])

func on_jump_destination_entered_valid_area():
	valid_jump_destinations += 1
	print("Entered valid jump area (%d total)" % valid_jump_destinations)

func on_jump_destination_exited_valid_area():
	valid_jump_destinations -= 1
	print("Exited valid jump area (%d total)" % valid_jump_destinations)