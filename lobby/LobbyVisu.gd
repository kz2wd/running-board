extends Control
class_name LobbyVisu

@onready var start_game_button: Button = $StartGameButton

@onready var lobby: Lobby = $Lobby

@onready var player_container: VBoxContainer = $PlayerContainer

@onready var leave_button: Button = $LeaveButton

func _ready() -> void:
	if multiplayer.is_server():
		start_game_button.connect("button_down", _start_game)
	else:
		start_game_button.visible = false
	
	lobby.players_changed.connect(update_players)
	leave_button.button_down.connect(GameClient.ask_disconnect)

func _start_game():
	GameServer.request_game_start()
	
	
const CONNECTED_CLIENT_VISU = preload("uid://df7dv7mfmgyhm")

func update_players():
	print("updating players")
	for child in player_container.get_children():
		child.queue_free()
	for player in lobby.connected_client.values():
		var new_visu: ConnectedClientVisu = CONNECTED_CLIENT_VISU.instantiate()
		new_visu.initialize(player)
		player_container.add_child(new_visu)
