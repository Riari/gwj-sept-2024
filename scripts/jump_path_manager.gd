class_name JumpPathManager
extends Node2D

@export var path_scene = preload("res://scenes/partials/jump-path.tscn")
@export var path_lifetime = 3.0 # Time until a spawned path is destroyed

var paths = []
var lifetimes = []

# Spawns a path at the given position. The returned path lasts for path_lifetime.
func request_path_at(spawn_pos: Vector2, direction: int) -> PathFollow2D:
	var path: Node2D = path_scene.instantiate()
	add_child(path)
	if direction < 0.0:
		path.scale.x = -1.0
	path.position = spawn_pos
	paths.push_back(path)
	lifetimes.push_back(path_lifetime)
	return path.get_node("PathFollow2D")

func _process(delta: float) -> void:
	for i in range(lifetimes.size() - 1, -1, -1):
		lifetimes[i] -= delta
		if lifetimes[i] < 0.0:
			lifetimes.pop_at(i)
			paths[i].queue_free()
			paths.pop_at(i)