extends Node

@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var tracks: Array[AudioStream] = []
@export var volume_adjustments: Array[float] = []

var tween: Tween
var current_track: int

const VOLUME_MAX = 0.0
const VOLUME_MIN = -80.0
const FADE_DURATION = 2.0
const FADE_TYPE = Tween.TransitionType.TRANS_SINE

func start_tween(from: float, to: float) -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	stream_player.volume_db = from
	tween.tween_property(stream_player, "volume_db", to + volume_adjustments[current_track], FADE_DURATION).set_trans(FADE_TYPE)

func fade_out() -> void:
	start_tween(VOLUME_MAX, VOLUME_MIN)

func fade_in(track_index: int) -> void:
	if track_index >= tracks.size():
		print("Tried to play non-existent track!")
		return

	play(track_index, VOLUME_MIN)
	start_tween(VOLUME_MIN, VOLUME_MAX)

func play(track_index: int, volume_db: float = VOLUME_MAX) -> bool:
	if track_index >= tracks.size():
		print("Tried to play non-existent track!")
		return false

	current_track = track_index
	stream_player.stream = tracks[track_index]
	stream_player.volume_db = volume_db + volume_adjustments[track_index]
	stream_player.play()
	return true
