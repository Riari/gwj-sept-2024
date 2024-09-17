extends Control

const FILE_JSON_TOWERS = "res://data/towers.json"

@export var item_preview_scene = preload("res://scenes/ui/item-preview.tscn")

@onready var towers_section: GridContainer = $Towers

func _ready() -> void:
	var utils = Utils.new()
	var tower_data = utils.load_json(FILE_JSON_TOWERS)
	
	for tower in tower_data["Towers"]:
		var preview_scene = item_preview_scene.instantiate()
		print(tower)
		var preview_image = Image.load_from_file(tower["PreviewImage"])
		preview_scene.item_image_texture = ImageTexture.create_from_image(preview_image)
		preview_scene.item_name = tower["Name"]
		preview_scene.item_price = int(tower["Price"])
		towers_section.add_child(preview_scene)