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
func start_game(player_data: Array):
	print("start game at " + str(multiplayer.get_unique_id()) + " called from " + str(multiplayer.get_remote_sender_id()))
	var board: Board = Board.new()
	
	var after_change_scene = func(game_scene):
		game_scene.set_board(board)
		GameServer.init_board(board)
		board.set_player_data(player_data)
		board.start_game()
	await Utils.change_scene_and_run(GAME, after_change_scene)
	
	
