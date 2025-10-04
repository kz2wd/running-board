extends Node
class_name DrawnCards

var drawn_info: Dictionary = {}

static func create(info = {}) -> DrawnCards:
	var cards = DrawnCards.new()
	cards.drawn_info = info
	return cards
	
func add_player_info(player: Player, drawn_cards: Array[Card]):
	
	drawn_info[player.client.client_id] = drawn_cards.map(func(it: Card): return it.type)
	
func serialize() -> Dictionary:
	return drawn_info

func get_player_cards(player: Player) -> Array[Card]:
	var result: Array[Card] = []
	for card_type: int in drawn_info[player.client.client_id]:
		result.append( Card.from_type(card_type))
	return result
	
static func deserialize(data: Dictionary):
	return DrawnCards.create(data)
