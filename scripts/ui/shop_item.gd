extends BaseButton

signal item_selected(item_data: Dictionary)
signal item_deselected

var item_image_texture: CompressedTexture2D
var item_image_scale = 1.0
var item_data = {}

@onready var item_image: TextureRect = $ImageContainer/Image
@onready var item_name_label: Label = $NameLabel
@onready var item_price_label: Label = $PriceLabel

func _ready() -> void:
	item_image.texture = item_image_texture
	item_image.scale = Vector2(item_image_scale, item_image_scale)
	item_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item_name_label.text = item_data["Name"]
	item_price_label.text = "%d" % item_data["Price"]

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		item_selected.emit(item_data)
	else:
		item_deselected.emit()
