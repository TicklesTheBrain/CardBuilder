extends Node
class_name CardContainer

@export var maxCards: int = -1
@export var cards: Array[CardData] = []
@export var bustCounter: ContainerCounter
@export var feedContainer: CardContainer # Container which is reshuffled if container is empty on drawCard function
@export var disposeContainer: CardContainer # Container to which things are disposed to on disposeCards call
@export var addTriggerType: CardEffect.triggerType
@export var modifiers: Array[Modifier]
@export var overrideRevealed: bool = false
@export var overrideRevealedState: bool = true

var ownerActor: Actor
var originMarker: Marker2D #TODO: THIS IS UGLY, need to fix this somehow

signal cardAdded(card: CardData)
signal cardRemoved(card: CardData)
signal shuffled()

func _ready():
	var parent = get_parent()
	if parent is Actor:
		ownerActor = parent

func removeCard(cardToRemove: CardData) -> bool:
	if cards.has(cardToRemove):
		cards.erase(cardToRemove)
		cardRemoved.emit(cardToRemove)
		return true
	return false

func getFreeSpace():
	if maxCards == -1:
		return maxCards
	else:
		return maxCards - cards.size()

func triggerAll(triggerType: CardEffect.triggerType):
	for card in cards:
		await card.triggerEffect(triggerType)

func addCard(cardToAdd: CardData, addToTop: bool = false) -> bool:

	#TODO: need to cleanup this order so it is bulletproof here. since trigger effect can sometimes add more cards with their own effects, the order on card added events is important for order
	#of the cards, which is a cosmetic incosistency, but might cause further fuckyness later on.

	if not checkFull():
		if addToTop:
			cards.push_front(cardToAdd)
		else:
			cards.push_back(cardToAdd)
		
		if overrideRevealed:
			cardToAdd.revealed = overrideRevealedState

		cardToAdd.container = self
		cardToAdd.triggerEffect(addTriggerType)
		Events.cardAdded.emit(self, cardToAdd)
		cardAdded.emit(cardToAdd)
		Events.gameStateChange.emit()
		return true
	return false

func checkFull() -> bool:
	return maxCards >= 0 and cards.size() >= maxCards

func checkEmpty() -> bool:
	return cards.size() == 0

func shuffle():
	cards.shuffle()
	shuffled.emit()

func getTop() -> CardData:
	return cards.front()

func getLast(toLast: int = 1) -> CardData:
	var ind = cards.size() - toLast
	assert(ind >= 0 and ind < cards.size())
	return cards[ind]

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
		if modifier is ParamModifier and modifier.type == type:			
			currValue = modifier.calculate(ctxt, currValue, card)
	
	return currValue

func disposeAll(containerToDisposeTo: CardContainer = disposeContainer):
	print('dispose triggered')
	while (not checkEmpty()):
		if containerToDisposeTo.checkFull():
			print('dispose container full')
			return
		var card = getTop()
		disposeCard(card, containerToDisposeTo)

func disposeCard(cardToDispose: CardData, containerToDisposeTo: CardContainer = disposeContainer):
	if containerToDisposeTo.checkFull():
		print('dispose container full')
		return
	removeCard(cardToDispose)
	containerToDisposeTo.addCard(cardToDispose)


func getTotalValue():
	return cards.reduce(func(acc, card): return acc+card.getValue(), 0)

func getModifiedBustValue(bustValue: int):
	for mod in modifiers:
		if mod is CounterModifier and mod.type == ContainerCounter.countWhat.VALUE:
			bustValue = mod.calculate(self, bustValue)

	return bustValue
