extends Node
class_name Board


#signal on_player_join(player: Player)
#signal on_player_leave(player: Player)
#signal on_player_disconnect(player: Player)
#signal on_player_reconnect(player: Player)
signal on_turn_starting(turn: int)

signal on_game_starting
signal on_move_phase_start

signal on_other_player_card_choice(player_id: int, card_index: int, is_final: bool)
signal on_player_choice_start

var players: Dictionary[int, Player] = {}

var global_deck: Deck


var turn: int = 0
var max_distance: int = 100
var players_to_play: Array[Player] = []

var drawn_cards: Array[Card] = []

signal __move_phase


func _ready():
	global_deck = Deck.create_global_deck()
	GameServer.init_board(self)
	GameServer.signal_ready.rpc_id(1)
	 # Connected deferred to prevent stack overflow
	__move_phase.connect(start_move_phase, ConnectFlags.CONNECT_DEFERRED)

func set_player_data(player_data: Array):
	for p in player_data:
		var player = Player.from_dict(p)
		players[player.client.client_id] = player
	print("Set board player data: " + str(players))
	
func prepare_card_pick():
	players_to_play = players.values()
	players_to_play.sort_custom(func(p1: Player, p2: Player): p1.progress < p2.progress)
	tell_player_to_choose()

func get_next_player():
	if players_to_play.is_empty():
		return null
	return players_to_play[0]


func go_to_next_player():
	players_to_play.pop_front()
	
	if players_to_play.is_empty():
		__move_phase.emit()
		return
		
	tell_player_to_choose()

func draw_from_global_deck():
	for player in players_to_play:
		drawn_cards.append(global_deck.draw_card())

var player_final_choices: Dictionary = {}

func get_sender_player() -> Player:
	var id = multiplayer.get_remote_sender_id()
	return players[id]

@rpc("any_peer", "call_local", "reliable")
func untrusted_player_card_choice(unstrusted_choice: int, is_final_choice: bool) -> bool:
	if unstrusted_choice > len(drawn_cards):
		return false
	
	if not multiplayer.is_server():
		return false
	
	var player: Player = get_sender_player()
	
	if is_final_choice:
		if player != get_next_player():
			return false
		
		set_other_player_choice.rpc(player.client.client_id, unstrusted_choice, true)
		go_to_next_player()
		
	elif players_to_play.has(player):
		set_other_player_choice.rpc(player.client.client_id, unstrusted_choice, false)
	else:
		return false
	
	return true


@rpc("authority", "call_local", "reliable")
func set_other_player_choice(player_id: int, unstrusted_choice: int, final_choice: bool) -> bool:
	if unstrusted_choice > len(drawn_cards):
		return false
		
	on_other_player_card_choice.emit(player_id, unstrusted_choice, final_choice)
	return true

func tell_player_to_choose():
	_remote_tell_player_to_choose.rpc_id(get_next_player().client.client_id)

@rpc("authority", "call_local", "reliable")
func _remote_tell_player_to_choose():
	on_player_choice_start.emit()

@rpc("authority", "call_local", "reliable")
func start_game(player_data: Array):
	set_player_data(player_data)
	on_game_starting.emit()

@rpc("authority", "call_local", "reliable")
func start_turn(card_types: Array):
	turn += 1
	prepare_card_pick()
	for type in card_types:
		drawn_cards.append(Card.from_type(type))
		print("adding local card " + str(type))
	
	print("Starting turn")
	on_turn_starting.emit()

func start_move_phase():
	if not multiplayer.is_server():
		return
	print("Starting move phase")
	# draw cards from player decks
	# Send the cards to the players
	# move the players
	# trigger new turn
	remote_start_move_phase.rpc()
	
@rpc("authority", "call_local", "reliable")
func remote_start_move_phase():
	on_move_phase_start.emit()
	
	
