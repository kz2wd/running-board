extends Node
class_name Lobby

"""
This script is responsible for handling players in the waiting lobby

It should manage:
	- Collecting the players
	- Player changing their name
	
For the authority:
	- Kicking player
	- Starting game  
	
"""
func _ready() -> void:
	print("Created lobby at: " + str(multiplayer.get_unique_id()))
	
	if not multiplayer.is_server():
		return
	GameServer.lobby = self
	
var connected_client: Dictionary[int, ConnectedClient] = {}
signal players_changed


@rpc("authority", "call_local", "reliable")
func add_player(client_data: Dictionary, emit=true):
	var remote_client: ConnectedClient = ConnectedClient.from_dict(client_data)
	connected_client[remote_client.client_id] = remote_client
	if emit:
		players_changed.emit()

@rpc("authority", "call_local", "reliable")
func set_player_list(player_list_data: Array):
	connected_client = {}
	for player_data in player_list_data:
		add_player(player_data, false)
	players_changed.emit()

@rpc("authority", "call_local", "reliable")
func change_player_name(untrusted_id: int, player_name: String):
	if untrusted_id not in connected_client.keys():
		return
	connected_client[untrusted_id].change_name(player_name) 
	
@rpc("authority", "call_local", "reliable")
func set_player_ready(untrusted_id: int):
	if untrusted_id not in connected_client.keys():
		return
	connected_client[untrusted_id].change_ready_status(true)
	players_changed.emit()

@rpc("authority", "call_local", "reliable")
func remove_player(id: int):
	connected_client.erase(id)
	players_changed.emit()

const GAME = preload("uid://fnyowjyucwet")

@rpc("authority", "call_local", "reliable")
func set_game_scene():
	Utils.log("set game scene")
	get_tree().change_scene_to_packed(GAME)	
	
	
	
