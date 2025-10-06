extends Control
class_name ConnectedClientVisu

var connected_client: ConnectedClient

@onready var name_input: LineEdit = $NameInput
@onready var kick_button: Button = $KickButton
@onready var status_label: Label = $StatusLabel


func initialize(client: ConnectedClient):
	connected_client = client

func _ready() -> void:
	kick_button.visible = multiplayer.is_server() and connected_client.client_id != multiplayer.get_unique_id()
	name_input.editable = connected_client.client_id == multiplayer.get_unique_id()
	kick_button.button_down.connect(ask_server_for_kick)
	name_input.text_submitted.connect(change_player_name)
	connected_client.on_ready_change.connect(update_status)
	connected_client.on_name_change.connect(update_name)
	update_status()
	update_name()

func ask_server_for_kick():
	GameServer.disconnect_peer(connected_client.client_id)

func change_player_name(new_text: String):
	GameServer.untrusted_name_change.rpc_id(1, new_text)
	
func update_name():
	if name_input != null:
		name_input.text = connected_client.client_name

func update_status():
	if status_label != null:
		status_label.text = "Pret" if connected_client.is_ready else "En attente"
