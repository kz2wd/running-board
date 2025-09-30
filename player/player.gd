extends Node
class_name Player

var deck: Deck

var progress: int = 0
var lane: int = 0

var soft_fracture: bool = false
var hard_fracture: bool = false


func add_fracture():
	if soft_fracture:
		hard_fracture = true
	else:
		soft_fracture = true


func get_distance(distance: int) -> int:
	if not hard_fracture:
		return distance
	return int(distance / 2.0)


func refresh_soft_fracture():
	soft_fracture = false
