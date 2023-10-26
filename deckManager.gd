extends Node
class_name DeckManager

@export var deck: Array[CardData] = []

func buildNewDeck():
	const cardsToBuild = 13
	const cardType = "T"

	for i in range(cardsToBuild):
		var newCard = CardData.new()
		newCard.value = i+1
		newCard.type = cardType
		newCard.cardText = "Placeholder"
		newCard.cost = randi_range(0,3)
		newCard.stats = StatData.new()
		newCard.stats.attack = randi_range(1,2)
		newCard.stats.defence = randi_range(0,1)
		deck.push_back(newCard)