extends Node
class_name Client
"""
This is a client script.

"""
var SAVE_PATH: String
func _ready() -> void:
	SAVE_PATH = SaveManager.save_path + "player_ids.json"

func start_client(ip_address, port) -> void:
	multiplayer.connected_to_server.connect(after_server_connect)
	multiplayer.connection_failed.connect(func(): print("Failed to connect!"))
	multiplayer.server_disconnected.connect(func(): print("Server disconnected!"))

	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip_address, port)
	if err != OK:
		push_error("Client creation failed: %s" % str(err))
		return
	multiplayer.multiplayer_peer = peer
	print("Starting client to " + str(ip_address) + ":" + str(port))

func get_or_create_player_uuid_for_game(game_id: String) -> String:
	# Load existing dictionary (or empty one if no file)
	var data: Dictionary = {}
	if FileAccess.file_exists(SAVE_PATH):
		var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var text = f.get_as_text()
		f.close()
		if text.length() > 0:
			data = JSON.parse_string(text) if text != "" else {}
	
	# If this game already has a uuid, return it
	if data.has(game_id):
		return data[game_id]
	
	# Otherwise create one, save it, and return it
	var uuid = Utils.generate_uuid_v4()
	data = {game_id: uuid}
	
	var fi = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	fi.store_string(JSON.stringify(data))
	fi.close()
	
	return uuid
	
const LOBBY = preload("uid://cpn13l2lxicjb")

func after_server_connect():
	get_tree().change_scene_to_packed(LOBBY)
	print("client Connected successfully!")


@rpc("authority", "reliable")
func send_game_id(game_id: String):
	var player_id = get_or_create_player_uuid_for_game(game_id)
	GameServer.ask_join_game.rpc_id(1, player_id, "default name")
