extends CardContainer
class_name DeckManager

@export var emptyCardArray: Array[EmptyCardData]

func buildNewEmptyDeck():	
	for empty in emptyCardArray:
		for i in range(empty.amount):
			var newCard = CardData.new()
			newCard.value = empty.value
			newCard.type = empty.type
			newCard.cardText = "Placeholder"
			newCard.cost = empty.cost
			newCard.stats = StatData.new()
			newCard.stats.attack = randi_range(1,2)
			newCard.stats.defence = randi_range(0,1)
			newCard.onPlayEffects = empty.onPlayEffects
			cards.push_back(newCard)