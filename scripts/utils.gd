class_name Utils
extends Node

func load_json(path: String) -> Dictionary:
	var json_as_string = FileAccess.get_file_as_string(path)
	var json_as_dict = JSON.parse_string(json_as_string)
	assert(json_as_dict, "Invalid JSON!")
	return json_as_dict

# From https://www.croben.com/2020/10/add-commas-on-floats-or-ints-in-gdscript.html
func number_format(value: int) -> String:
	var str_value: String = str(value)
	var loop_end: int = 0 if value > -1 else 1
	for i in range(str_value.length()-3, loop_end, -3):
		str_value = str_value.insert(i, ",")

	return str_value