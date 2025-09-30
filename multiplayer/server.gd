extends Node
class_name Server

"""
This is a server connection script.
Every client need to include it to communicate with the server!

This script also handles the server logic.
"""

@export var PORT = 9500
@export var MAX_CLIENTS = 7

var clients: Dictionary[String, ConnectedClient]

signal player_joined_game
signal player_left_game

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_CLIENTS)
	if err != OK:
		push_error("Server creation failed: %s" % str(err))
		return
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(on_peer_try_join)
	print("STARTING SERVER at port " + str(PORT))
	prepare_new_game()
	
func disconnect_peer():
	multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_remote_sender_id())
	
func on_peer_try_join(id: int):
	print("A client joined!!")
	if len(clients) >= MAX_CLIENTS + 1:
		disconnect_peer()
		return
	
	GameClient.send_game_id.rpc_id(id, current_game_uuid)

var current_game_uuid: String = ""

func prepare_new_game():
	current_game_uuid = Utils.generate_uuid_v4()

var board: Board = null
var lobby: Lobby = null

var game_started: bool = false

func has_game_started() -> bool:
	return game_started

@rpc("any_peer", "call_local", "reliable")
func ask_join_game(uuid: String, client_name: String):
	print(str(multiplayer.get_remote_sender_id()) + " has asked to join " + str(multiplayer.get_unique_id()))
	if not multiplayer.is_server():
		return
	if has_game_started():
		disconnect_peer()
		return
	
	if clients.has(uuid):
		# Player is trying to reconnect
		print("PLAYER ALREADY CONNECTED WTF")
		pass
	else:
		# Player is connecting for the first time
		var remote_client = ConnectedClient.create(
			multiplayer.get_remote_sender_id(),
			client_name)
		validate_join_player(uuid, remote_client)
		
func validate_join_player(uuid: String, remote_client: ConnectedClient):
	clients[uuid] = remote_client
	print("adding player to lobby from " + str(multiplayer.get_unique_id()))
	lobby.add_player.rpc(remote_client.client_id, remote_client.client_name)
	# Inform the new player about the previously connected ones
	for previously_connected_client in clients.values():
		lobby.add_player.rpc_id(remote_client.client_id, previously_connected_client.client_id, previously_connected_client.client_name)
	
	player_joined_game.emit()

func init_lobby():
	if not multiplayer.is_server():
		return
	var lob_scene: LobbyVisu = get_tree().current_scene
	GameServer.lobby = lob_scene.lobby
	get_tree().scene_changed.disconnect(init_lobby)
	
func init_board(b: Board):
	if not multiplayer.is_server():
		return
	GameServer.board = b
	for client_id in clients.values():
		board.add_player.rpc(client_id)

func init_lobby_on_server():
	if not multiplayer.is_server():
		return
	var lob_scene: LobbyVisu = get_tree().current_scene
	GameServer.lobby = lob_scene.lobby
	get_tree().scene_changed.disconnect(init_lobby_on_server)
	var fake_remote_client = ConnectedClient.create(
			multiplayer.get_unique_id(),
			"Server")
	clients["Local_player"] = fake_remote_client
	lobby.add_player(fake_remote_client.client_id, fake_remote_client.client_name)
	player_joined_game.emit()
	
