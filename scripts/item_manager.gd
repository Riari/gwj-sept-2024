extends Node2D

signal fish_changed(total: int, adjustment: int)
signal started_item_placing
signal item_cancellation_confirmed
signal finished_item_placing
signal placed_item_count_increased(total: int)

@export var tower_segment_scene: PackedScene = preload("res://scenes/partials/tower/segment.tscn")
@export var item_bed_scene: PackedScene = preload("res://scenes/partials/items/types/bed.tscn")
@export var item_food_scene: PackedScene = preload("res://scenes/partials/items/types/food.tscn")
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
var purchased_item_data = {}
var purchased_item_node

var placed_items = 0

func _ready() -> void:
	fish_changed.emit(fish, 0)

func _input(event: InputEvent) -> void:
	if event is InputEventAction && event.is_action_pressed("cancel") && mode != Mode.IDLE:
		confirm_purchase_cancellation()

func _process(_delta: float) -> void:
	var is_valid_placement = false
	match mode:
		Mode.IDLE:
			return
		Mode.PLACING_TOWER:
			var layout: Array = purchased_item_data["TowerConfiguration"]["Layout"]
			is_valid_placement = grid.can_place_tower_at_hovered_cell(layout)
			if Input.is_action_pressed("place_item") && is_valid_placement:
				grid.place_tower_at_hovered_cell(layout)
				purchased_item_node.global_position = grid.get_hovered_cell_position()
				finish_placing_item()
				return

		Mode.PLACING_ITEM:
			is_valid_placement = grid.can_place_item_at_hovered_cell()
			if Input.is_action_pressed("place_item") && is_valid_placement:
				grid.place_item_at_hovered_cell()
				purchased_item_node.global_position = grid.get_hovered_cell_position()
				placed_items += 1
				placed_item_count_increased.emit(placed_items)
				finish_placing_item()
				return

	if is_valid_placement:
		purchased_item_node.modulate = color_valid
		purchased_item_node.global_position = grid.get_hovered_cell_position()
	else:
		purchased_item_node.modulate = color_invalid
		purchased_item_node.global_position = get_global_mouse_position()

func finish_placing_item() -> void:
	purchased_item_node.modulate = Color.WHITE
	purchased_item_node.enable_areas()
	purchased_item_node.on_place()
	grid.disable_preview()
	finished_item_placing.emit()
	mode = Mode.IDLE

func _on_shop_item_purchased(item_data: Dictionary) -> void:
	adjust_fish(-item_data["Price"])
	purchased_item_data = item_data
	started_item_placing.emit()

	match item_data["Type"]:
		"tower":
			grid.enable_preview(Grid2D.PlaceMode.TOWER)
			purchased_item_node = on_tower_purchased(item_data)
		"item":
			grid.enable_preview(Grid2D.PlaceMode.ITEM)
			purchased_item_node = on_item_purchased(item_data)
		_:
			print("Unrecognized item type")
			return

func _on_shop_item_purchase_cancelled() -> void:
	confirm_purchase_cancellation()

func confirm_purchase_cancellation() -> void:
	purchased_item_node.queue_free()
	adjust_fish(purchased_item_data["Price"])
	purchased_item_data = {}
	item_cancellation_confirmed.emit()
	mode = Mode.IDLE
	grid.disable_preview()

func on_tower_purchased(tower_data: Dictionary) -> Node2D:
	var node: TowerSegment = tower_segment_scene.instantiate()
	tower_segments.add_child(node)
	node.configure(tower_data["TowerConfiguration"]["PlatformWidth"], tower_data["TowerConfiguration"]["PlatformOffset"])
	node.modulate = color_invalid
	node.disable_areas()
	mode = Mode.PLACING_TOWER
	return node

func on_item_purchased(item_data: Dictionary) -> Node2D:
	var scene: PackedScene
	match item_data["Subtype"]:
		"bed": scene = item_bed_scene
		"food": scene = item_food_scene
		"toy": scene = item_toy_scene

	var node = scene.instantiate()
	items.add_child(node)
	node.configure(item_data)
	node.modulate = color_invalid
	node.disable_areas()
	mode = Mode.PLACING_ITEM
	return node

func adjust_fish(amount: int) -> void:
	fish += amount
	fish_changed.emit(fish, amount)

func _on_cat_manager_cat_interaction_ended(_cat: Cat, item: Item) -> void:
	adjust_fish(item.item_data["Earns"])
