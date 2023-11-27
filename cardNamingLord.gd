extends Node

@export var cardFaceReference: Array[CardInfoDisplayProperties]

var usedNames: Array[String] = []

func askToNameCard(cardData: CardData):
	var unusedNames = cardFaceReference.map(func(p): return p.identifier).filter(func(c): return not usedNames.has(c))
	assert (unusedNames.size() > 0)
	var randomName = unusedNames.pick_random()
	usedNames.push_back(randomName)
	cardData.cardName = randomName

func registerUsedName(used: String):
	assert(cardFaceReference.map(func(p): return p.identifier).has(used))
	usedNames.push_back(used)

func getCardFace(cardName: String):
	return cardFaceReference.find(func(p): return p.identifier == cardName)
	