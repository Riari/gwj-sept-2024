extends ColorRect

@onready var checkbox_disable_hints: CheckBox = $CheckBoxDisableHints
@onready var volume_slider_master: HSlider = $MasterVolumeSlider
@onready var volume_slider_music: HSlider = $MusicVolumeSlider
@onready var volume_slider_ui: HSlider = $UIVolumeSlider
@onready var volume_slider_cats: HSlider = $CatsVolumeSlider

var master_bus_index: int
var music_bus_index: int
var ui_bus_index: int
var cats_bus_index: int

func _ready() -> void:
	checkbox_disable_hints.button_pressed = SettingsManager.disable_hints

	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	ui_bus_index = AudioServer.get_bus_index("UI")
	cats_bus_index = AudioServer.get_bus_index("Cats")

	volume_slider_master.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))
	volume_slider_music.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	volume_slider_ui.value = db_to_linear(AudioServer.get_bus_volume_db(ui_bus_index))
	volume_slider_cats.value = db_to_linear(AudioServer.get_bus_volume_db(cats_bus_index))

func _on_check_box_disable_hints_toggled(toggled_on: bool) -> void:
	SettingsManager.set_disable_hints(toggled_on)

func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))

func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))

func _on_ui_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(ui_bus_index, linear_to_db(value))

func _on_cats_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(cats_bus_index, linear_to_db(value))

func _on_button_return_pressed() -> void:
	visible = false
