extends Node
class_name Card

enum CARD_TYPE {RUN_10M, RUN_9M, RUN_8M, RUN_7M, RUN_6M, RUN_5M, RUN_4M, RUN_3M,
RUN_2M, RUN_1M, RUN_0M, FRACTURE_0M, FRACTURE_15M, BREATH_3M, RUN_LAPS_AMOUNT}


var type: CARD_TYPE = CARD_TYPE.RUN_0M

func instantiate_card(card_type: CARD_TYPE):
	self.type = card_type


static func from_type(source_type: CARD_TYPE) -> Card:
	var card = Card.new()
	card.instantiate_card(source_type)
	return card
	

func play():
	return
