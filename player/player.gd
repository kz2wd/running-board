extends Node
class_name Player

var deck: Deck = Deck.new()

var progress: int = 0
var lane: int = 0

var fracture: int = 0

var client: ConnectedClient

static func from_client(connected_client: ConnectedClient) -> Player:
	var player: Player = Player.new()
	player.client = connected_client
	return player


func add_fracture():
	fracture += 1


func get_distance(distance: int) -> int:
	if fracture < 2:
		return distance
	return int(distance / float(fracture))


func refresh_soft_fracture():
	if fracture == 1:
		fracture = 0
		
func play():
	var card: Card = deck.draw_random_card()
	card.apply(self)

static func create(arg_progress: int, arg_lane: int, arg_fracture: int, arg_client: ConnectedClient):
	var p = Player.new()
	p.progress = arg_progress
	p.lane = arg_lane
	p.fracture = arg_fracture
	p.client = arg_client
	return p

# Serialization
func to_dict() -> Dictionary:
	return {
		"progress": progress,
		"lane": lane,
		"fracture": fracture,
		"client": client.to_dict(),
	}
	
static func from_dict(data: Dictionary) -> Player:
	return create(data["progress"], data["lane"], data["fracture"], 
	ConnectedClient.from_dict(data["client"]))
