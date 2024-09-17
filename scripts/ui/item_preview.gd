extends Control

@export var item_image_texture: ImageTexture
@export var item_name = ""
@export var item_price = 100

@onready var item_image: TextureRect = $Image
@onready var item_name_label: Label = $NameLabel
@onready var item_price_label: Label = $PriceLabel

func _ready() -> void:
	item_image.texture = item_image_texture
	item_name_label.text = "%s" % item_name
	item_price_label.text = "%d" % item_price