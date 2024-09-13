extends CharacterBody2D

enum State
{
	IDLE,
	WALK,
	RUN,
}

var state_to_anim = {
	State.IDLE: "Idle",
	State.WALK: "Walk",
	State.RUN: "Run",
}

var state_to_speed = {
	State.IDLE: 0.0,
	State.WALK: 40.0,
	State.RUN: 120.0,
}

var current_state: State = State.IDLE
var state_change_interval = [2.0, 5.0]
var next_state_change_in: float
var state_change_timer = 0.0

var rng = RandomNumberGenerator.new()

@onready var sprite = get_node("AnimatedSprite2D")

func _ready() -> void:
	pick_next_state_change_interval()

func _process(delta: float) -> void:
	state_change_timer += delta

	if state_change_timer >= next_state_change_in:
		pick_next_state(true)
		sprite.play(state_to_anim[current_state])
		pick_next_state_change_interval()
		state_change_timer = 0
		
		velocity = Vector2(state_to_speed[current_state], 0.0)
		var should_change_direction = rng.randi_range(0, 1)
		if should_change_direction == 1:
			velocity[0] *= -1.0

		if current_state != State.IDLE:
			sprite.flip_h = velocity[0] < 0.0

func _physics_process(delta: float) -> void:
	move_and_slide()

func pick_next_state(must_change: bool = false) -> void:
	var new_state = State.values().pick_random()
	if must_change && new_state == current_state:
		pick_next_state()
	else:
		current_state = new_state

func pick_next_state_change_interval():
	next_state_change_in = rng.randf_range(state_change_interval[0], state_change_interval[1])
