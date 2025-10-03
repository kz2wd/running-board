extends Control
class_name CardVisu

var card: Card
@onready var display: Sprite2D = $Display

func set_card(arg_card: Card):
	card = arg_card

func _ready() -> void:
	display.texture = card.get_visual()
