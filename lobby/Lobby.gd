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
	
var connected_client: Dictionary[int, ConnectedClient] = {}
signal players_changed


@rpc("authority", "call_local", "reliable")
func add_player(client_id: int, client_name: String):
	var remote_client: ConnectedClient = ConnectedClient.create(client_id, client_name)
	connected_client[client_id] = remote_client
	print("adding player to lobby at: " + str(multiplayer.get_unique_id()))
	players_changed.emit()


@rpc("authority", "call_local", "reliable")
func change_player_name(id: int, player_name: String):
	connected_client[id].client_name = player_name
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
	
	
	
