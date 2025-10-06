extends Node
class_name Board


#signal on_player_join(player: Player)
#signal on_player_leave(player: Player)
#signal on_player_disconnect(player: Player)
#signal on_player_reconnect(player: Player)
signal on_turn_starting(turn: int)

signal on_game_starting
signal on_move_phase_start

signal on_players_move(player: Player, cards: Array[Card])

signal on_other_player_card_choice(player_id: int, card_index: int, is_final: bool)
signal on_player_choice_start

signal on_winner(winner: Player)

var players: Dictionary[int, Player] = {}

var global_deck: Deck


var turn: int = 0
var max_distance: int = 10
var players_to_play: Array[Player] = []

var drawn_cards: Array[Card] = []

signal __move_phase
signal __start_turn


func _ready():
	global_deck = Deck.create_global_deck()
	GameServer.init_board(self)
	GameServer.signal_ready.rpc_id(1)
	GameClient.current_board = self
	 # Connected deferred to prevent stack overflow
	__move_phase.connect(start_move_phase, ConnectFlags.CONNECT_DEFERRED)
	__start_turn.connect(start_board_turn, ConnectFlags.CONNECT_DEFERRED)

func set_player_data(player_data: Array):
	for p in player_data:
		var player = Player.from_dict(p)
		players[player.client.client_id] = player
	print("Set board player data: " + str(players))

# Returns winner Player or null 
func check_for_winner() -> Player:
	var winners: Array[Player] = []
	for player: Player in players.values():
		if player.progress >= max_distance:
			winners.append(player)
	if winners.is_empty():
		return null
	sort_players_by_progress(winners)
	var winner = winners[-1]
	return winner


@rpc("authority", "call_local", "reliable")
func remote_show_winner(winner_id: int):
	Utils.log("showing winner")
	on_winner.emit(players[winner_id])
	await get_tree().create_timer(3.0).timeout
	# Send player back to lobby...
	GameClient.reconnect_to_lobby()

func start_board_turn():
	if not multiplayer.is_server():
		return
	var winner : Player = check_for_winner()
	if winner != null:
		GameServer.set_all_clients_unready()
		remote_show_winner.rpc(winner.client.client_id)
		return
	
	print("Drawing central cards")
	prepare_card_pick()
	var turn_cards = global_deck.draw_cards(len(players_to_play))
	var turn_types: Array = turn_cards.map(func(it: Card): return it.type)
	remote_start_turn.rpc(turn_types)

func sort_players_by_progress(player_list: Array[Player]):
	# Furthest player is the one with the biggest progress
	# If progresses are equals, then the smallest lane is the further
	var player_sorter = func(p1: Player, p2: Player):
		if p1.progress == p2.progress:
			return p1.lane > p2.lane
		return p1.progress < p2.progress
	player_list.sort_custom(player_sorter)

func prepare_card_pick():
	if not multiplayer.is_server():
		return
	player_final_choices = {}
	players_to_play = players.values()
	sort_players_by_progress(players_to_play)
	for player in players_to_play:
		print(str(player.client.client_id) + " - " + str(player.progress))
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
	drawn_cards = []
	for player in players_to_play:
		drawn_cards.append(global_deck.draw_card())

var player_final_choices: Dictionary = {}

func get_sender_player() -> Player:
	var id = multiplayer.get_remote_sender_id()
	return players[id]

@rpc("any_peer", "call_local", "reliable")
func untrusted_player_card_choice(unstrusted_choice: int, is_final_choice: bool) -> bool:
	if not multiplayer.is_server():
		return false
	
	if unstrusted_choice > len(drawn_cards):
		return false
	
	var player: Player = get_sender_player()
	
	if is_final_choice:
		if player != get_next_player():
			return false
			
		if player_final_choices in player_final_choices.values():
			return false
		var choice = unstrusted_choice
		player_final_choices[player] = choice 
		set_other_player_choice.rpc(player.client.client_id, unstrusted_choice, true)
		player.deck.add_card(drawn_cards[choice])
		go_to_next_player()
		
	elif players_to_play.has(player):
		set_other_player_choice.rpc(player.client.client_id, unstrusted_choice, false)
	else:
		return false
	
	return true

func update_player_deck(player_id: int, card_index: int):
	var player: Player = players[player_id]
	var card: Card = drawn_cards[card_index]
	player.deck.add_card(card)
	

@rpc("authority", "call_local", "reliable")
func set_other_player_choice(player_id: int, unstrusted_choice: int, final_choice: bool) -> bool:
	if unstrusted_choice > len(drawn_cards):
		return false
		
	if final_choice:
		update_player_deck(player_id, unstrusted_choice)
	
	on_other_player_card_choice.emit(player_id, unstrusted_choice, final_choice)
	return true

func tell_player_to_choose():
	if not multiplayer.is_server():
		return
	_remote_tell_player_to_choose.rpc_id(get_next_player().client.client_id)

@rpc("authority", "call_local", "reliable")
func _remote_tell_player_to_choose():
	on_player_choice_start.emit()

@rpc("authority", "call_local", "reliable")
func start_game(player_data: Array):
	set_player_data(player_data)
	on_game_starting.emit()

@rpc("authority", "call_local", "reliable")
func remote_start_turn(card_types: Array):
	turn += 1
	drawn_cards = []
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
	var player_drawn_cards: DrawnCards = DrawnCards.create()
	for player: Player in players.values():
		var card: Card = player.deck.draw_random_card()
		var card_list = card.get_card_list(player)
		player_drawn_cards.add_player_info(player, card_list)
	# Send the cards to the players and the new positions
	
	remote_start_move_phase.rpc(player_drawn_cards.serialize())
	
	# wait a bit before new turn
	await get_tree().create_timer(1.0).timeout
	
	# trigger new turn
	__start_turn.emit()

func is_player_local(player: Player) -> bool:
	return player.client.client_id == multiplayer.get_unique_id()

@rpc("authority", "call_local", "reliable")
func remote_start_move_phase(drawn_card_data: Dictionary):
	Utils.log("starts local move phase")
	on_move_phase_start.emit()
	var player_drawn_cards := DrawnCards.create(drawn_card_data)
	for player: Player in players.values():
		var cards = player_drawn_cards.get_player_cards(player)
		player.play(cards)
		on_players_move.emit(player, cards)
			
	
