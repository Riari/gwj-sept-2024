extends Node

@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var tracks: Array[AudioStream] = []
@export var volume_adjustments: Array[float] = []

enum Mode
{
	STOPPED,
	PLAYING,
	PLAYING_PLAYLIST,
	LOOPING_PLAYLIST,
}

var tween: Tween
var current_track: int
var mode := Mode.STOPPED
var is_delaying = false
var current_playlist: Array[int]
var current_playlist_index: int
var playlist_delay_between_tracks: float
var playlist_delay_timer = 0.0

const VOLUME_MAX = 0.0
const VOLUME_MIN = -80.0
const FADE_DURATION = 2.0
const FADE_TYPE = Tween.TransitionType.TRANS_SINE

func _process(delta: float) -> void:
	if mode == Mode.PLAYING_PLAYLIST || mode == Mode.LOOPING_PLAYLIST && is_delaying:
		playlist_delay_timer += delta
		if playlist_delay_timer > playlist_delay_between_tracks:
			current_playlist_index += 1
			if current_playlist_index >= current_playlist.size():
				if mode == Mode.LOOPING_PLAYLIST:
					current_playlist_index = 0
				else:
					mode = Mode.STOPPED
					return

			play(current_playlist[current_playlist_index])
			is_delaying = false

func _on_audio_stream_player_finished() -> void:
	playlist_delay_timer = 0.0
	is_delaying = true

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

func start_playlist(playlist_tracks: Array[int], delay_between: float, looping: bool = true) -> void:
	current_playlist = playlist_tracks
	current_playlist_index = 0
	fade_in(playlist_tracks[0])
	playlist_delay_between_tracks = delay_between
	mode = Mode.LOOPING_PLAYLIST if looping else Mode.PLAYING_PLAYLIST