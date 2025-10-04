extends Control
class_name BoardVisu

@export var board: Board
@export var lane_width: float = 60.0
@export var race_length: float = 800.0

const PLAYER_VISU = preload("uid://c8xhg8b38u5c0")
@onready var player_container: Control = $PlayerContainer

@onready var card_choice_display: ControlChoiceSelector = $CardChoiceDisplay
@onready var choice_label: Label = $ChoiceLabel


func _ready() -> void:
	if board == null:
		push_warning("No board connected to board visu")
	else:
		board.on_turn_starting.connect(redraw)
		board.on_turn_starting.connect(func(): card_choice_display.reset(board))
		board.on_game_starting.connect(redraw)
		board.on_player_choice_start.connect(start_player_choice)
		card_choice_display.on_selection_change.connect(handle_card_choice)
		board.on_other_player_card_choice.connect(handle_other_player_choice)
		board.on_move_phase_start.connect(handle_move_phase)
		board.on_players_move.connect(handle_player_movement)

func handle_player_movement(player: Player, cards: Array[Card]):
	# TODO
	print("Player moved")
	redraw()
	pass

func handle_move_phase():
	card_choice_display.visible = false
	choice_label.visible = false


func handle_other_player_choice(player_id: int, card_index: int, is_final: bool):
	if player_id == multiplayer.get_unique_id():
		# Do not set our own choice as an external choice
		return
		
	card_choice_display.set_external_choice(board.players[player_id], card_index, is_final)
			
func handle_card_choice(choice: int, is_final: bool):
	if is_final:
		choice_label.visible = false 
	board.untrusted_player_card_choice.rpc_id(1, choice, is_final)

func get_player_race_progress(player: Player) -> float:
	return float(player.progress) / board.max_distance * race_length

func start_player_choice():
	choice_label.visible = true
	card_choice_display.enable_selection()

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
		
	print("Redrawing client board")
		
		

	
