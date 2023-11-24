extends CardContainer
class_name DeckManager

@export var debug: bool = true
@export var templatePackage: CardTemplatePackage

func populateContainerFromTemplate():
	var newCards = DeckManager.makeCardArrayFromTemplate(templatePackage.cards, debug)
	for card in newCards:
		addCard(card)

static func makeCardArrayFromTemplate(template: Array[EmptyCardData], onlyDebug: bool = false):

	var cardArray = [] as Array[CardData]
	for empty in template:
		if onlyDebug and not empty.debug:
			continue
		for i in range(empty.amount):
			var newCard = empty.duplicateSelf()
			cardArray.push_back(newCard)

	return cardArray
