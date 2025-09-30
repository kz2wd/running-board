extends Control
class_name ConnectedClientVisu

var connected_client: ConnectedClient

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func initialize(client: ConnectedClient):
	connected_client = client

func _ready() -> void:
	rich_text_label.text = connected_client.client_name
