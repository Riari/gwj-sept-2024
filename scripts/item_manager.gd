class_name ItemManager
extends Node2D

signal fish_changed(total: int, adjustment: int)
signal started_placing_tower
signal started_placing_item
signal cancelled_placing
signal finished_placing_tower
signal finished_placing_item
signal placed_item_count_changed(total: int)
signal item_selected(item: Item)

@export var tower_segment_scene: PackedScene = preload("res://scenes/partials/tower/segment.tscn")
@export var item_bed_scene: PackedScene = preload("res://scenes/partials/items/types/bed.tscn")
@export var item_food_scene: PackedScene = preload("res://scenes/partials/items/types/food.tscn")
@export var item_drink_scene: PackedScene = preload("res://scenes/partials/items/types/drink.tscn")
@export var item_toy_scene: PackedScene = preload("res://scenes/partials/items/types/toy.tscn")
@export var color_invalid = Color(.8, 0, .3, .65)
@export var color_valid = Color(0, .75, .65, .65)
@export var grid_query_interval = 0.05

@onready var grid: Grid2D = get_node("../Grid")
@onready var tower_segments: Node2D = get_node("../Tower/Segments")
@onready var items: Node2D = get_node("../Tower/Items")

enum Mode
{
	IDLE,
	PLACING_TOWER,
	PLACING_ITEM,
}

var fish = 1000

var mode: Mode = Mode.IDLE
var purchased_item_definition = {}
var purchased_item_node

var placed_items = 0

func _ready() -> void:
	fish_changed.emit(fish, 0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.is_action("cancel") && mode != Mode.IDLE:
			confirm_purchase_cancellation()
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	var is_valid_placement = false
	match mode:
		Mode.IDLE:
			return
		Mode.PLACING_TOWER:
			var layout: Array = purchased_item_definition["TowerConfiguration"]["Layout"]
			is_valid_placement = grid.can_place_tower_at_hovered_cell(layout)
			if Input.is_action_pressed("place_item") && is_valid_placement:
				grid.place_tower_at_hovered_cell(layout)
				purchased_item_node.global_position = grid.get_hovered_cell_position()
				finished_placing_tower.emit()
				finish_placing()
				return

		Mode.PLACING_ITEM:
			is_valid_placement = grid.can_place_item_at_hovered_cell()
			if Input.is_action_pressed("place_item") && is_valid_placement:
				var item_cell_coords = grid.place_item_at_hovered_cell()
				purchased_item_node.global_position = grid.get_hovered_cell_position()
				purchased_item_node.grid_coords = item_cell_coords
				placed_items += 1
				placed_item_count_changed.emit(placed_items)
				finished_placing_item.emit()
				finish_placing()
				return

	if is_valid_placement:
		purchased_item_node.modulate = color_valid
		purchased_item_node.global_position = grid.get_hovered_cell_position()
	else:
		purchased_item_node.modulate = color_invalid
		purchased_item_node.global_position = get_global_mouse_position()

func finish_placing() -> void:
	purchased_item_node.modulate = Color.WHITE
	purchased_item_node.enable_areas()
	purchased_item_node.on_place()
	grid.disable_preview()
	mode = Mode.IDLE

func _on_shop_item_purchased(item_definition: Dictionary) -> void:
	adjust_fish(-item_definition["Price"])
	purchased_item_definition = item_definition

	match item_definition["Type"]:
		"tower":
			grid.enable_preview(Grid2D.PlaceMode.TOWER)
			purchased_item_node = on_tower_purchased(item_definition)
			started_placing_tower.emit()
		"item":
			grid.enable_preview(Grid2D.PlaceMode.ITEM)
			purchased_item_node = on_item_purchased(item_definition)
			started_placing_item.emit()
		_:
			print("Unrecognized item type")
			return

func _on_shop_item_purchase_cancelled() -> void:
	confirm_purchase_cancellation()

func confirm_purchase_cancellation() -> void:
	purchased_item_node.queue_free()
	adjust_fish(purchased_item_definition["Price"])
	purchased_item_definition = {}
	cancelled_placing.emit()
	mode = Mode.IDLE
	grid.disable_preview()

func on_tower_purchased(tower_data: Dictionary) -> Node2D:
	var node: TowerSegment = tower_segment_scene.instantiate()
	tower_segments.add_child(node)
	node.define(tower_data["TowerConfiguration"]["PlatformWidth"], tower_data["TowerConfiguration"]["PlatformOffset"])
	node.modulate = color_invalid
	node.disable_areas()
	mode = Mode.PLACING_TOWER
	return node

func on_item_purchased(item_definition: Dictionary) -> Node2D:
	var scene: PackedScene
	match item_definition["Subtype"]:
		"bed": scene = item_bed_scene
		"food": scene = item_food_scene
		"drink": scene = item_drink_scene
		"toy": scene = item_toy_scene

	var node: Item = scene.instantiate()
	items.add_child(node)
	node.define(item_definition)
	node.modulate = color_invalid
	node.disable_areas()
	node.selected.connect(_on_item_selected)
	node.sold.connect(_on_item_sold)
	mode = Mode.PLACING_ITEM
	return node

func adjust_fish(amount: int) -> void:
	fish += amount
	fish_changed.emit(fish, amount)

func request_replacement(item: Item) -> bool:
	if item.definition["ReplacePrice"] < fish:
		adjust_fish(item.definition["ReplacePrice"])
		return true

	return false

func _on_cat_manager_cat_interaction_ended(_cat: Cat, item: Item) -> void:
	adjust_fish(item.definition["Earns"])

func _on_item_selected(item: Item) -> void:
	item_selected.emit(item)

func _on_item_sold(item: Item) -> void:
	adjust_fish(int(item.definition["Price"] / 2))
	grid.remove_item_at(item.grid_coords)
	item.queue_free()
	placed_items -= 1
	placed_item_count_changed.emit(placed_items)