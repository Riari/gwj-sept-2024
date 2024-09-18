extends Node2D

@export var textures: Array[CompressedTexture2D] = []
@export var bounds_min = Vector2(-1472, -960)
@export var bounds_max = Vector2(1472, -7744)
@export var frequency: int = 128
@export var jitter: float = 32.0
@export var distribution_seed: int = 12345
@export var threshold: float = 0.65

var rng = RandomNumberGenerator.new()
var positions = []
var image_indices = []

func _ready() -> void:
	if textures.size() == 0:
		print("Clouds script has no cloud textures!")
		return

	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = distribution_seed

	var count = 0
	for x in range(bounds_min.x, bounds_max.x, frequency):
		for y in range(bounds_min.y, bounds_max.y, -frequency):
			var noise_normalized = (noise.get_noise_2d(x, y) + 1.0) / 2.0
			if noise_normalized > threshold:
				positions.push_back(Vector2(x, y))
				image_indices.push_back(rng.randi_range(0, textures.size() - 1))
				count += 1
	
	print("Generated %d clouds!" % count)

func _draw() -> void:
	for i in positions.size():
		var cloud_position = positions[i]
		var image_index = image_indices[i]
		var jitter_x = rng.randf_range(-jitter, jitter)
		var jitter_y = rng.randf_range(-jitter, jitter)
		draw_texture(textures[image_index], cloud_position + Vector2(jitter_x, jitter_y))