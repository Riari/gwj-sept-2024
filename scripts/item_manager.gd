extends Node2D

signal fish_changed(quantity: int)
signal started_item_placing
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
	fish_changed.emit(fish)

func _process(_delta: float) -> void:
	match mode:
		Mode.IDLE:
			return
		Mode.PLACING_TOWER:
			var is_valid_placement = grid.can_accept_tower_at_hovered_cell(purchased_item_data["TowerConfiguration"]["Cells"])

			if Input.is_action_pressed("place_item") && is_valid_placement:
				purchased_item_node.modulate = Color.WHITE
				purchased_item_node.enable_areas()
				purchased_item_node.on_place()
				grid.place_tower_at_hovered_cell(purchased_item_data["TowerConfiguration"]["Cells"])
				finished_item_placing.emit()
				grid.enable_ingame_preview = false
				mode = Mode.IDLE
				return

			if is_valid_placement:
				purchased_item_node.modulate = color_valid
				purchased_item_node.position = grid.get_hovered_cell_position()
			else:
				purchased_item_node.modulate = color_invalid
				purchased_item_node.global_position = get_global_mouse_position()
		Mode.PLACING_ITEM:
			pass

func _on_shop_item_purchased(item_data: Dictionary) -> void:
	adjust_fish(-item_data["Price"])
	purchased_item_data = item_data
	started_item_placing.emit()
	grid.enable_ingame_preview = true

	match item_data["Type"]:
		"tower":
			purchased_item_node = on_tower_purchased(item_data)
		"item":
			purchased_item_node = on_item_purchased(item_data)
		_:
			print("Unrecognized item type")
			return

func on_tower_purchased(tower_data: Dictionary) -> Node2D:
	var node: TowerSegment = tower_segment_scene.instantiate()
	tower_segments.add_child(node)
	node.configure(tower_data["TowerConfiguration"]["PlatformWidth"], tower_data["TowerConfiguration"]["PlatformOffset"])
	node.modulate = color_invalid
	node.disable_areas()
	mode = Mode.PLACING_TOWER
	return node

func on_item_purchased(item_data: Dictionary) -> Node2D:
	var node = load(item_data["Scene"])
	items.add_child(node)
	mode = Mode.PLACING_ITEM
	return node

func adjust_fish(amount: int) -> void:
	fish += amount
	fish_changed.emit(fish)
