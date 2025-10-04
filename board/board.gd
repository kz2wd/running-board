extends Node
class_name Board


#signal on_player_join(player: Player)
#signal on_player_leave(player: Player)
#signal on_player_disconnect(player: Player)
#signal on_player_reconnect(player: Player)
signal on_turn_starting(turn: int)

#signal on_game_initialized

var players: Dictionary[int, Player] = {}

var global_deck: Deck


var turn: int = 0
var max_distance: int = 100
var players_to_play: Array[Player] = []

var drawn_cards: Array[Card] = []

func _ready():
	global_deck = Deck.create_global_deck()
	GameServer.init_board(self)
	GameServer.signal_ready.rpc_id(1)

func set_player_data(player_data: Array):
	for p in player_data:
		var player = Player.from_dict(p)
		players[player.client.client_id] = player
	print("Set board player data: " + str(players))
	
func prepare_card_pick():
	players_to_play = players.values()
	players_to_play.sort_custom(func(p1: Player, p2: Player): p1.progress < p2.progress)

func get_next_player():
	return players_to_play[0]

func go_to_next_player():
	players_to_play.pop_front()

#
#@rpc("authority", "call_local", "reliable", 0)
#func add_player(id: int):
	#players[id] = Player.new()
	#on_player_join.emit(players[id])
	#print("Add player to internal board")

func draw_from_global_deck():
	for player in players_to_play:
		drawn_cards.append(global_deck.draw_card())

@rpc("any_peer", "call_local", "reliable")
func untrusted_player_card_choice(unstrusted_choice: int):
	if not multiplayer.is_server():
		return false
		
	var id = multiplayer.get_remote_sender_id()
	var player = players[id]
	if player != get_next_player():
		return false
	
	if unstrusted_choice > len(drawn_cards):
		return false
	var choice = unstrusted_choice
	var chosen_card = drawn_cards.pop_at(choice)
	
	player.deck.add_card(chosen_card)
	go_to_next_player()

@rpc("authority", "call_local", "reliable")
func start_game(player_data: Array):
	set_player_data(player_data)

@rpc("authority", "call_local", "reliable")
func start_turn(card_types: Array):
	turn += 1
	prepare_card_pick()
	for type in card_types:
		drawn_cards.append(Card.from_type(type))
		print("adding local card " + str(type))
	
	print("Starting turn")
	on_turn_starting.emit()
