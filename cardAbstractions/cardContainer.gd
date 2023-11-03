extends Node
class_name CardContainer

@export var maxCards: int = -1
@export var cards: Array[CardData] = []
@export var bustCounter: ContainerCounter
@export var feedContainer: CardContainer
@export var cardsNeedDisplays: bool
@export var addTriggerType: PlayEffect.triggerType
@export var modifiers: Array[ContainerModifier]

signal cardAdded(card: CardData)
signal cardRemoved(card: CardData)

func removeCard(cardToRemove: CardData) -> bool:
	if cards.has(cardToRemove):
		cards.erase(cardToRemove)
		cardRemoved.emit(cardToRemove)
		return true
	return false

func addCard(cardToAdd: CardData) -> bool:
	if not checkFull():
		cards.push_back(cardToAdd)
		cardToAdd.container = self
		cardToAdd.triggerEffect(addTriggerType)
		cardAdded.emit(cardToAdd)
		return true
	return false

func checkFull() -> bool:
	return maxCards >= 0 and cards.size() >= maxCards

func checkEmpty() -> bool:
	return cards.size() == 0

func shuffle():
	cards.shuffle()

func getTop() -> CardData:
	return cards.front()

func getAll() -> Array[CardData]:
	return cards.duplicate()

func removeAll():
	var allCards = cards.duplicate()
	for card in allCards:
		removeCard(card)

func drawCard():
	if checkEmpty():
		if feedContainer:
			if feedContainer.checkEmpty():
				return
		else:
			return
		while (not checkFull() and not feedContainer.checkEmpty()):
			var newCard = feedContainer.drawCard()
			addCard(newCard)
	var cardToDraw = getTop()
	removeCard(cardToDraw)
	return cardToDraw

func applyModifiers(type: CardParam.ParamType, card: CardData, value: int, ctxt: GameStateContext):
	var currValue = value
	for modifier in modifiers:
		if modifier.type == type:			
			modifier.calculate(ctxt, currValue, card)
	return currValue

