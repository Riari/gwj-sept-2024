extends Node2D

signal fish_changed(quantity: int)

var grid: Grid
var fish = 500
var purchased_item = {}

func _ready() -> void:
	fish_changed.emit(fish)
	grid = get_tree().current_scene.get_node("Grid")
	assert(grid, "No Grid found in scene!")

func adjust_fish(amount: int) -> void:
	fish += amount
	fish_changed.emit(fish)

func _on_shop_item_purchased(item_data: Dictionary) -> void:
	adjust_fish(-item_data["Price"])
