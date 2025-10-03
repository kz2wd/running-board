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

var username: String = "Host"

func reset():
	clients = {}
	current_game_uuid = ""
	board = null
	lobby = null
	game_started = false
	

func start_server(player_name: String) -> void:
	username = player_name
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_CLIENTS)
	if err != OK:
		push_error("Server creation failed: %s" % str(err))
		return
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(on_peer_try_join)
	peer.peer_disconnected.connect(on_peer_disconnect)
	print("STARTING SERVER at port " + str(PORT))
	prepare_new_game()
	
func disconnect_peer(id: int):
	multiplayer.multiplayer_peer.disconnect_peer(id)
	
func on_peer_try_join(id: int):
	print("A client joined!!")
	if len(clients) >= MAX_CLIENTS + 1:
		disconnect_peer(id)
		return
	
	GameClient.send_game_id.rpc_id(id, current_game_uuid)

func uuid_from_id(id: int) -> String:
	for uuid: String in clients.keys():
		var client = clients[uuid]
		if client.client_id == id:
			return uuid
	return ""


func on_peer_disconnect(id: int):
	print("A client has disconnected")
	if has_game_started():
		# do not remove the player in case of disconnection
		return
	
	var uuid: String = uuid_from_id(id)
	clients.erase(uuid)
	player_left_game.emit()
	if lobby != null:
		lobby.remove_player.rpc(id)

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
		disconnect_peer(multiplayer.get_remote_sender_id())
		return
	
	if clients.has(uuid):
		# Player is trying to reconnect
		print("PLAYER ALREADY CONNECTED HANDLE ME :D")
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
			username)
	clients["Local_player"] = fake_remote_client
	lobby.add_player(fake_remote_client.client_id, fake_remote_client.client_name)
	player_joined_game.emit()

@rpc("any_peer", "call_local", "reliable")
func untrusted_name_change(new_name: String):
	var sender_id: int = multiplayer.get_remote_sender_id()
	if lobby == null:
		return
	var uuid: String = uuid_from_id(sender_id)
	if clients.has(uuid):
		clients[uuid].client_name = new_name
	lobby.change_player_name.rpc(sender_id, new_name)
	
func request_game_start():
	# make player list
	var lane = 0
	var serialized: Array[Dictionary] = []
	for uuid in clients.keys():
		var c: ConnectedClient = clients[uuid]
		var player = Player.create(0, lane, 0, c)
		lane += 1
		serialized.append(player.to_dict())
	lobby.start_game.rpc(serialized)
