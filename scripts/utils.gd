class_name Utils
extends Node

func load_json(path: String):
	var json_as_string = FileAccess.get_file_as_string(path)
	var json_as_dict = JSON.parse_string(json_as_string)
	assert(json_as_dict, "Invalid JSON!")
	return json_as_dict