extends CardContainer
class_name DeckManager

@export var debug: bool = true
@export var debugRandomiseStats: bool
@export var templateDeck: Array[EmptyCardData]

func buildCardsFromTemplate():
	for empty in templateDeck:
		if debug and not empty.debug:
			continue
		for i in range(empty.amount):
			var newCard = empty.duplicateSelf()
			if debugRandomiseStats:
				newCard.stats = StatData.new()
				newCard.stats.attack = randi_range(1,2)
				newCard.stats.defence = randi_range(0,1)

			addCard(newCard)
