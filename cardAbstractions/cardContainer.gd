extends Node
class_name CardContainer

@export var maxCards: int = -1
@export var cards: Array[CardData] = []
@export var bustCounter: ContainerCounter
@export var feedContainer: CardContainer # Container which is reshuffled if container is empty on drawCard function
@export var disposeContainer: CardContainer # Container to which things are disposed to on disposeCards call
@export var addTriggerType: PlayEffect.triggerType
@export var modifiers: Array[Modifier]

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
		Events.cardAdded.emit(self, cardToAdd)
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

func addModifier(mod: Modifier):
	modifiers.append(mod)

func applyModifiers(type: CardParam.ParamType, card: CardData, value: int, ctxt: GameStateContext):
	var currValue = value
	for modifier in modifiers:
		if modifier.type == type:			
			currValue = modifier.calculate(ctxt, currValue, card)
	
	return currValue

func disposeAll(containerToDisposeTo: CardContainer = disposeContainer):
	print('dispose triggered')
	while (not checkEmpty()):
		if containerToDisposeTo.checkFull():
			print('dispose container full')
			return
		var card = getTop()
		removeCard(card)
		containerToDisposeTo.addCard(card)

func getTotalValue():
	return cards.reduce(func(acc, card): return acc+card.getValue(), 0)



