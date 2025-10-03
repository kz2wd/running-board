extends Node
class_name Card

enum CARD_TYPE {RUN_10M, RUN_9M, RUN_8M, RUN_7M, RUN_6M, RUN_5M, RUN_4M, RUN_3M,
RUN_2M, RUN_1M, RUN_0M, FRACTURE_0M, FRACTURE_15M, BREATH_3M, RUN_LAPS_AMOUNT}

static var card_visuals: Dictionary[CARD_TYPE, Resource] = {
	CARD_TYPE.RUN_10M: preload("uid://cs60n3l5wmjw2"),
	CARD_TYPE.RUN_9M: preload("uid://cc216fd0pcvkx"),
	CARD_TYPE.RUN_8M: preload("uid://b4ccw8pfswdaf"),
	CARD_TYPE.RUN_7M: preload("uid://cqsa4i1ofkchu"),
	CARD_TYPE.RUN_6M: preload("uid://cqsa4i1ofkchu"),
	CARD_TYPE.RUN_5M: preload("uid://b6a0atc1ltn4s"),
	CARD_TYPE.RUN_4M: preload("uid://balrdlrlwk0r8"),
	CARD_TYPE.RUN_3M: preload("uid://b6a5akw831ef5"),
	CARD_TYPE.RUN_2M: preload("uid://5l371kbtokqb"),
	CARD_TYPE.RUN_1M: preload("uid://v87khpi337db"), 
	CARD_TYPE.RUN_0M: preload("uid://bxlugwmov7ldn"),
	CARD_TYPE.FRACTURE_0M: preload("uid://rqqvbecwmfwh"),
	CARD_TYPE.FRACTURE_15M: preload("uid://6qg8uyjtcka7"),
	CARD_TYPE.BREATH_3M: preload("uid://dfn8l718ksstd"),
	CARD_TYPE.RUN_LAPS_AMOUNT: preload("uid://c8jq7cba42nfj"),
}

static var card_run_distance: Dictionary[CARD_TYPE, int] = {
	CARD_TYPE.RUN_10M: 10,
	CARD_TYPE.RUN_9M: 9,
	CARD_TYPE.RUN_8M: 8,
	CARD_TYPE.RUN_7M: 7,
	CARD_TYPE.RUN_6M: 6,
	CARD_TYPE.RUN_5M: 5,
	CARD_TYPE.RUN_4M: 4,
	CARD_TYPE.RUN_3M: 3,
	CARD_TYPE.RUN_2M: 2,
	CARD_TYPE.RUN_1M: 1,
	CARD_TYPE.FRACTURE_15M: 15,
	CARD_TYPE.BREATH_3M: 3,
}

static var card_fracture: Array[CARD_TYPE] = [
	CARD_TYPE.FRACTURE_0M, 
	CARD_TYPE.FRACTURE_15M,
]

# List of card that does not remove soft fracture effect
static var card_no_fracture_refresh: Array[CARD_TYPE] = [
	CARD_TYPE.BREATH_3M
]

var type: CARD_TYPE = CARD_TYPE.RUN_0M

func instantiate_card(card_type: CARD_TYPE):
	self.type = card_type


static func from_type(source_type: CARD_TYPE) -> Card:
	var card = Card.new()
	card.instantiate_card(source_type)
	return card

static var missing_visual: Resource = preload("uid://bxlugwmov7ldn")
func get_visual() -> Resource:
	if card_visuals.has(type):
		return card_visuals[type]
	return missing_visual


func apply(player: Player):
	# Distance
	var run_distance: int = 0
	if card_run_distance.has(type):
		run_distance += card_run_distance[type]
	player.progress += player.get_distance(run_distance)
	
	# Fracture
	if card_fracture.has(type):
		player.add_fracture()
	elif not card_no_fracture_refresh.has(type):
		player.refresh_soft_fracture()
	
	# Specials
	match type:
		CARD_TYPE.BREATH_3M:
			player.play()
		CARD_TYPE.RUN_LAPS_AMOUNT:
			player.progress += player.get_distance(GameServer.board.turn)
	
