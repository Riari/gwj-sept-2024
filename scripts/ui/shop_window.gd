class_name ShopWindow
extends Control

signal item_purchased(item_data: Dictionary)

const FILE_JSON_ITEMS = "res://data/items.json"

@export var item_scene = preload("res://scenes/ui/shop-item.tscn")

@onready var inventory: GridContainer = $InventoryContainer/MarginContainer/Inventory
@onready var selected_item_description: Label = $SelectedItemDescription
@onready var button_buy: Button = $ButtonBuy

var selected_item_data = {}

func _ready() -> void:
	var utils = Utils.new()
	var item_data = utils.load_json(FILE_JSON_ITEMS)
	
	for item in item_data["Items"]:
		var item_node = item_scene.instantiate()
		item_node.item_image_texture = load(item["Sprite"])
		if item["Type"] == "item":
			item_node.item_image_scale = 2.0
			item_node.position.y = 0

		item_node.item_data = item
		inventory.add_child(item_node)
		item_node.connect("item_selected", _on_item_selected)
		item_node.connect("item_deselected", _on_item_deselected)

func _on_button_close_pressed() -> void:
	visible = false

func _on_button_buy_pressed() -> void:
	visible = false
	item_purchased.emit(selected_item_data)

func _on_item_selected(item_data: Dictionary) -> void:
	selected_item_data = item_data
	selected_item_description.text = item_data["Description"]
	button_buy.disabled = false

func _on_item_deselected() -> void:
	selected_item_data = {}
	selected_item_description.text = ""
	button_buy.disabled = true

func on_fish_changed(total: int) -> void:
	for item in inventory.get_children():
		item.set_available(item.item_data["Price"] <= total)

func open() -> void:
	visible = true

func close() -> void:
	visible = false