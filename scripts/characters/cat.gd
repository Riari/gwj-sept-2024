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

var state_to_speed = {
	State.IDLE: 0.0,
	State.WALK: 40.0,
	State.RUN: 150.0,
	State.FALL: 40.0
}

var current_state: State = State.IDLE
var state_change_interval = [2.0, 5.0]
var next_state_change_in: float
var state_change_timer = 0.0
var was_on_floor = true

var rng = RandomNumberGenerator.new()

const GRAVITY = 150.0

@onready var sprite = get_node("AnimatedSprite2D")

func _ready() -> void:
	pick_next_state_change_interval()

func _process(delta: float) -> void:
	if !was_on_floor && is_on_floor():
		execute_next_state()
		velocity = Vector2(state_to_speed[current_state], 0.0)
		was_on_floor = true
	elif was_on_floor && !is_on_floor():
		execute_state(State.FALL)
		was_on_floor = false
		velocity = Vector2(state_to_speed[current_state], GRAVITY)
		print("Started falling")

	if is_on_floor():
		state_change_timer += delta
		if state_change_timer >= next_state_change_in:
			execute_next_state()
			sprite.play(state_to_anim[current_state])
			state_change_timer = 0

			velocity = Vector2(state_to_speed[current_state], 0.0)
			var should_change_direction = rng.randi_range(0, 1)
			if should_change_direction == 1:
				velocity.x *= -1.0

			if current_state != State.IDLE:
				sprite.flip_h = velocity.x < 0.0

func _physics_process(delta: float) -> void:
	move_and_slide()

func execute_state(state: State) -> void:
	current_state = state
	sprite.play(state_to_anim[current_state])

func pick_next_state() -> State:
	var new_state = State.values().pick_random()
	if new_state == current_state || new_state == State.FALL:
		return pick_next_state()
	else:
		return new_state

func execute_next_state() -> void:
	execute_state(pick_next_state())
	pick_next_state_change_interval()

func pick_next_state_change_interval():
	next_state_change_in = rng.randf_range(state_change_interval[0], state_change_interval[1])
