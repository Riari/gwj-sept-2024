extends CharacterBody2D

enum State
{
	IDLE,
	WALK,
	RUN,
	FALL,
}

var state_to_anim = {
	State.IDLE: "Idle",
	State.WALK: "Walk",
	State.RUN: "Run",
	State.FALL: "Fall",
}

const GRAVITY = 150.0

var state_to_velocity = {
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

var rng = RandomNumberGenerator.new()

@onready var sprite = get_node("AnimatedSprite2D")

func _ready() -> void:
	pick_next_state_change_interval()

func _process(delta: float) -> void:
	if !was_on_floor && is_on_floor():
		execute_random_state()
		was_on_floor = true
	elif was_on_floor && !is_on_floor():
		execute_state(State.FALL)
		was_on_floor = false
	elif was_on_floor && is_on_floor():
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

	sprite.play(state_to_anim[current_state])
	var new_velocity = state_to_velocity[current_state]
	velocity = Vector2(new_velocity.x * direction, new_velocity.y)

func pick_next_state() -> State:
	var new_state = State.values().pick_random()
	if new_state == current_state || new_state == State.FALL:
		return pick_next_state()
	else:
		return new_state

func execute_random_state() -> void:
	execute_state(pick_next_state())
	pick_next_state_change_interval()

func pick_next_state_change_interval():
	next_state_change_in = rng.randf_range(state_change_interval[0], state_change_interval[1])
