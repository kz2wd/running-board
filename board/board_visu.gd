extends Control
class_name BoardVisu

@export var board: Board
@export var lane_width: float = 60.0
@export var race_length: float = 500.0

const PLAYER_VISU = preload("uid://c8xhg8b38u5c0")
@onready var player_container: Control = $PlayerContainer
@onready var card_choice_display: ControlChoiceSelector = $CardChoiceDisplay


func _ready() -> void:
	if board == null:
		push_warning("No board connected to board visu")
	else:
		board.on_turn_starting.connect(redraw)
		board.on_turn_starting.connect(card_choice_display.refresh_children)
		board.on_game_starting.connect(redraw)
		
		card_choice_display.on_selection_change.connect(
			func (selection:int): board.untrusted_player_card_choice.rpc_id(1, selection))

func get_player_race_progress(player: Player) -> float:
	return player.progress / (board.max_distance * race_length)


func set_player_pos(player: Player):
	var player_visu: PlayerVisu = PLAYER_VISU.instantiate()
	player_container.add_child(player_visu)
	player_visu.position.y = -lane_width * player.lane
	player_visu.position.x = get_player_race_progress(player)


func redraw():
	for child in player_container.get_children():
		child.queue_free()
	for player: Player in board.players.values():
		set_player_pos(player)
		
	show_card_choice()
	print("Redrawing client board")
		
		
const CARD = preload("uid://booq1bvduv3ph")

func show_card_choice():
	for card: Card in board.drawn_cards:
		var cardVisu: CardVisu = CARD.instantiate()
		cardVisu.set_card(card)
		card_choice_display.add_child(cardVisu)
