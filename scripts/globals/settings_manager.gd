extends Node

var disable_hints := false
var volume_levels = {
	"Master": 1.0,
	"Music": 1.0,
	"UI": 1.0,
	"Cats": 1.0,
}

func set_disable_hints(value: bool) -> void:
	disable_hints = value