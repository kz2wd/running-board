extends Control
class_name PlayerVictoryVisu

var player: Player
@onready var label: Label = $Label

func show_winner(winner: Player):
	visible = true
	player = winner
	label.text = str(player.client.client_name) + " remporte la partie!"
