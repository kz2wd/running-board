extends Control
class_name BoardVisu

@export var board: Board
@export var lane_width: float = 10.0
@export var race_length: float = 500.0

const PLAYER_VISU = preload("uid://c8xhg8b38u5c0")
@onready var player_container: Control = $PlayerContainer


func _ready() -> void:
	if board == null:
		push_warning("No board connected to board visu")
	else:
		board.connect("on_player_join", redraw)
	
func associate_board(b: Board):
	board = b
	board.connect("on_player_join", redraw)


func get_player_race_progress(player: Player) -> float:
	return player.progress / (board.max_distance * race_length)


func set_player_pos(player: Player):
	var player_visu: PlayerVisu = PLAYER_VISU.instantiate()
	player_container.add_child(player_visu)
	player_visu.position.y = lane_width * player.lane
	player_visu.position.x = get_player_race_progress(player)


func redraw():
	for child in player_container.get_children():
		child.queue_free()
	for player: Player in board.players.values():
		set_player_pos(player)
