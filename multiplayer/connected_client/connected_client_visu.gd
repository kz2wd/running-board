extends Control
class_name ConnectedClientVisu

var connected_client: ConnectedClient

@onready var name_input: LineEdit = $NameInput
@onready var kick_button: Button = $KickButton


func initialize(client: ConnectedClient):
	connected_client = client

func _ready() -> void:
	kick_button.visible = multiplayer.is_server() and connected_client.client_id != multiplayer.get_unique_id()
	name_input.text = connected_client.client_name
	name_input.editable = connected_client.client_id == multiplayer.get_unique_id()
	kick_button.button_down.connect(ask_server_for_kick)
	name_input.text_submitted.connect(change_player_name)

func ask_server_for_kick():
	GameServer.disconnect_peer(connected_client.client_id)

func change_player_name(new_text: String):
	GameServer.untrusted_name_change.rpc_id(1, new_text)
