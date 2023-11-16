extends CardContainer
class_name DeckManager

@export var debug: bool = true
@export var emptyCardArray: Array[EmptyCardData]

func buildNewEmptyDeck():
	for empty in emptyCardArray:
		if debug and not empty.debug:
			continue
		for i in range(empty.amount):
			var newCard = empty.duplicateSelf()
			newCard.stats = StatData.new()
			newCard.stats.attack = randi_range(1,2)
			newCard.stats.defence = randi_range(0,1)

			addCard(newCard)
