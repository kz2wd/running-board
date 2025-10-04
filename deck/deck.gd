class_name Deck extends Node

var rng = RandomNumberGenerator.new()

var cards: Array[Card]

signal on_card_drew(card: Card)
signal on_shuffle()
signal on_card_added(card: Card)

func draw_random_card(remove=false):
	var selected: Card = cards.pick_random()
	if remove:
		cards.erase(selected)
	on_card_drew.emit(selected)
	return selected
	
func draw_top_card(remove=false):
	var selected: Card = cards[0]
	if remove:
		cards.erase(selected)
	on_card_drew.emit(selected)
	return selected

func shuffle():
	cards.shuffle()
	on_shuffle.emit()
	
func add_card(card: Card, amount:int =1):
	for i in range(amount):
		cards.append(card)
		on_card_added.emit(card)
	
func try_remove_card(card: Card):
	cards.erase(card)

static func create_global_deck() -> Deck:
	var deck: Deck = Deck.new()
	deck.cards = []
	for key in Card.CARD_TYPE.values():
		deck.cards.append(Card.from_type(key))
	return deck

func draw_cards(amount: int) -> Array:
	var drawn_cards = []
	for i in range(amount):
		drawn_cards.append(draw_random_card())
	return drawn_cards
