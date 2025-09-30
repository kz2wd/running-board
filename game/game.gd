extends Control
class_name GameScene

@onready var board_visu: BoardVisu = $BoardVisu

func set_board(board: Board):
	board_visu.associate_board(board)
	add_child(board)
