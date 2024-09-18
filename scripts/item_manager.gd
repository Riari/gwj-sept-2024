extends Node2D

signal fish_changed(total: int, adjustment: int)
signal started_item_placing
signal item_cancellation_confirmed
signal finished_item_placing

@export var tower_segment_scene = preload("res://scenes/partials/tower/segment.tscn")
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

var fish = 500

var mode: Mode = Mode.IDLE
var purchased_item_data = {}
var purchased_item_node

func _ready() -> void:
	fish_changed.emit(fish, 0)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("cancel") && mode != Mode.IDLE:
		confirm_purchase_cancellation()
		return

	var is_valid_placement = false
	match mode:
		Mode.IDLE:
			return
		Mode.PLACING_TOWER:
			is_valid_placement = grid.can_accept_tower_at_hovered_cell(purchased_item_data["TowerConfiguration"]["Cells"])

			if Input.is_action_pressed("place_item") && is_valid_placement:
				grid.place_tower_at_hovered_cell(purchased_item_data["TowerConfiguration"]["Cells"])
				finish_placing_item()
				return
		Mode.PLACING_ITEM:
			is_valid_placement = grid.can_accept_item_at_hovered_cell()

			if Input.is_action_just_released("place_item") && is_valid_placement:
				grid.place_item_at_hovered_cell()
				finish_placing_item()
				return

	if is_valid_placement:
		purchased_item_node.modulate = color_valid
		purchased_item_node.position = grid.get_hovered_cell_position()
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
	grid.enable_preview()

	match item_data["Type"]:
		"tower":
			purchased_item_node = on_tower_purchased(item_data)
		"item":
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
	var scene: PackedScene = load(item_data["Scene"])
	var node = scene.instantiate()
	items.add_child(node)
	node.modulate = color_invalid
	node.disable_areas()
	mode = Mode.PLACING_ITEM
	return node

func adjust_fish(amount: int) -> void:
	fish += amount
	fish_changed.emit(fish, amount)

func _on_cat_interaction_complete(value: int) -> void:
	adjust_fish(value)