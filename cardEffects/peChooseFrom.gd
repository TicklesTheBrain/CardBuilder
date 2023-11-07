extends PlayEffect
class_name ChooseFrom

@export var amountOfCardsToChoose: int = 1
@export var amountOfCardsToChooseFrom: int = 2
@export var sourceOfCards: Game.ContainerPurposes
@export var destinationOfCards: Game.ContainerPurposes
@export var destinationOfUnchosenCards: Game.ContainerPurposes
@export var reshuffleDeckAfterwards: bool = false

var selectedCards: Array[CardData] = []
signal cardSelectionDone

func triggerSpecific(ctxt: GameStateContext):

	var source = ctxt.getContainerFromPurpose(sourceOfCards) as CardContainer
	var destination = ctxt.getContainerFromPurpose(destinationOfCards)
	var unchosenDestination = ctxt.getContainerFromPurpose(destinationOfUnchosenCards)

	Events.requestShowPocket.emit(getPocketText())

	var counter = 0
	while (not source.checkEmpty() and not destination.checkFull() and counter < amountOfCardsToChooseFrom):
		var card = source.drawCard()
		ctxt.pocket.addCard(card)
		counter+=1

	Selector.cardSelectionRequested.emit(ctxt.pocket, amountOfCardsToChoose, receiveSelection)

	await cardSelectionDone

	Events.requestHidePocket.emit()

	for card in selectedCards:
		ctxt.pocket.removeCard(card)
		if not destination.checkFull():
			destination.addCard(card)
		else:
			unchosenDestination.addCard(card)
	
	ctxt.pocket.disposeAll(ctxt.getContainerFromPurpose(destinationOfUnchosenCards))

	if reshuffleDeckAfterwards:
		ctxt.drawDeck.shuffle()

func getPocketText() -> String:
	
	var destination = convertContainerPurposeTo(destinationOfCards)	

	return "Choose {numChoose} cards to add your {destination}".format(
		{"numChoose": amountOfCardsToChoose, "destination": destination})


func getTextSpecific() -> String:
	
	var source =  convertContainerPurposeTo(sourceOfCards)
	var destination = convertContainerPurposeTo(destinationOfCards)
	var destination2verb = convertContainerPurposeTo(destinationOfUnchosenCards, true)

	return "Look at top {numFrom} cards of your {source}. Add {numChoose} to {destination} and {destination2verb} the rest".format(
		{"numFrom": amountOfCardsToChooseFrom, "source": source, "numChoose": amountOfCardsToChoose, "destination": destination, "destination2verb": destination2verb })

func receiveSelection(cards: Array[CardData]):
	selectedCards = cards
	cardSelectionDone.emit()

func convertContainerPurposeTo(purp: Game.ContainerPurposes, verb: bool = false):

	match purp:
		Game.ContainerPurposes.DECK:
			if verb: return "return to your deck"
			else: return "deck"
		Game.ContainerPurposes.HAND:
			if verb: return "add to your hand"
			else: return "hand"
		Game.ContainerPurposes.PLAY_AREA:
			if verb: return "play"
			else: return "played cards"
		Game.ContainerPurposes.DISCARD:
			if verb: return "discard"
			else: return "your discard"

