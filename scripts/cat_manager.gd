extends Node2D

signal cat_spawned(cat: Cat)
signal cat_selected(cat: Cat)
signal cat_interaction_ended(cat: Cat, item: Item)

@export var cats: Array[PackedScene] = []

@onready var spawn_point_left: Node2D = $SpawnPointLeft
@onready var spawn_point_right: Node2D = $SpawnPointRight

# The number of items required to trigger each progressive spawn.
# One spawn per threshold value.
const SPAWN_THRESHOLDS = [
	1, 3, 5, 7, 9, 11,
	14, 17, 20, 23, 26,
	30, 40, 50, 60, 70, 80, 90, 100,
	120, 140, 160, 180, 200,
	220, 240, 260, 280, 300,
	320, 340, 360, 380, 400,
	420, 440, 460, 480, 500,
	520, 540, 560, 580, 600,
	620, 640, 660, 680, 700,
]

const FILE_JSON_CATS = "res://data/cats.json"

var names = []
var descriptions = {}
var sound_sets = []

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	var utils = Utils.new()
	var cat_data = utils.load_json(FILE_JSON_CATS)
	names = cat_data["Names"]
	descriptions = cat_data["Descriptions"]
	for sound_set_json in cat_data["SoundSets"]:
		var meows: Array[AudioStream]
		var purrs: Array[AudioStream]
		for meow in sound_set_json["Meows"]:
			meows.push_back(load(meow))
		for purr in sound_set_json["Purrs"]:
			purrs.push_back(load(purr))

		sound_sets.push_back({ "Meows": meows, "Purrs": purrs })

func acquire_random_name() -> String:
	rng.randomize()
	var i = rng.randi_range(0, names.size() - 1)
	return names.pop_at(i)

func acquire_random_description() -> String:
	var part_1 = descriptions["PartOne"].pick_random()
	var part_2 = descriptions["PartTwo"].pick_random()

	return "%s %s" % [part_1, part_2]

func prepare_random_cat() -> Cat:
	var cat_scene = cats.pick_random()
	var cat_node: Cat = cat_scene.instantiate()
	var cat_name = acquire_random_name()
	var cat_description = acquire_random_description()
	var cat_sound_set = sound_sets.pick_random()
	cat_node.configure(cat_name, cat_description, cat_sound_set["Meows"], cat_sound_set["Purrs"])

	return cat_node

func spawn() -> void:
	if names.size() == 0:
		print("Unable to spawn more cats because we ran out of names :(")
		return

	# Choose the spawn point furthest from the camera
	var camera_position = get_viewport().get_camera_2d().global_position
	var left_distance = spawn_point_left.global_position.distance_squared_to(camera_position)
	var right_distance = spawn_point_right.global_position.distance_squared_to(camera_position)

	var spawn_from_left = left_distance > right_distance
	var spawn_point = spawn_point_left if spawn_from_left else spawn_point_right

	var cat = prepare_random_cat()
	add_child(cat)
	cat.global_position = spawn_point.global_position

	if spawn_from_left:
		cat.face_right()
	else:
		cat.face_left()
	
	cat_spawned.emit(cat)
	cat.selected.connect(on_cat_selected)
	cat.interaction_complete.connect(on_cat_interaction_ended)

func _on_item_manager_placed_item_count_increased(total: int) -> void:
	for threshold in SPAWN_THRESHOLDS:
		if total == threshold:
			spawn()

func on_cat_selected(cat: Cat) -> void:
	cat_selected.emit(cat)

func on_cat_interaction_ended(cat: Cat, item: Item) -> void:
	cat_interaction_ended.emit(cat, item)