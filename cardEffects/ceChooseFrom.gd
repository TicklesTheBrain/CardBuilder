extends CardEffect
class_name ChooseFrom

@export var amountOfCardsToChoose: int = 1
@export var amountOfCardsToChooseFrom: int = 2
@export var sourceOfCards: Actor.ContainerPurposes
@export var destinationOfCards: Actor.ContainerPurposes
@export var destinationOfUnchosenCards: Actor.ContainerPurposes
@export var reshuffleSourceAfterwards: bool = false
@export var reshuffleDestinationAfterwards: bool = false

var selectedCards: Array[CardData] = []
var pocketContainer: CardContainer

signal cardSelectionDone

func triggerSpecific(ctxt: GameStateContext):

	var actor = ctxt.getActorFromType(subjectActor)

	var source = actor.getContainerFromPurpose(sourceOfCards) as CardContainer
	var destination = actor.getContainerFromPurpose(destinationOfCards) as CardContainer
	var unchosenDestination = actor.getContainerFromPurpose(destinationOfUnchosenCards) as CardContainer

	if destination.getFreeSpace() != -1:
		amountOfCardsToChoose = min (destination.getFreeSpace(), amountOfCardsToChoose)

	PocketLord.requestNewPocket.emit(getPocketText(), receivePocket, amountOfCardsToChooseFrom)

	var counter = 0
	while (not source.checkEmpty() and not destination.checkFull() and counter < amountOfCardsToChooseFrom):
		var card = source.drawCard()
		pocketContainer.addCard(card)
		counter+=1

	InputLord.cardSelectionRequested.emit(pocketContainer, amountOfCardsToChoose, receiveSelection)
	
	await cardSelectionDone
	
	for card in selectedCards:
		pocketContainer.removeCard(card)
		if not destination.checkFull():
			destination.addCard(card)
		else:
			unchosenDestination.addCard(card)
			
	pocketContainer.disposeAll(unchosenDestination)
	PocketLord.requestClosePocket.emit(pocketContainer)
			
	if reshuffleSourceAfterwards:
		source.shuffle()

	if reshuffleDestinationAfterwards:
		destination.shuffle()

func receivePocket(pocket: CardContainer):
	pocketContainer = pocket

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

func convertContainerPurposeTo(purp: Actor.ContainerPurposes, verb: bool = false):

	match purp:
		Actor.ContainerPurposes.DECK:
			if verb: return "return to your deck"
			else: return "deck"
		Actor.ContainerPurposes.HAND:
			if verb: return "add to your hand"
			else: return "hand"
		Actor.ContainerPurposes.PLAY_AREA:
			if verb: return "play"
			else: return "played cards"
		Actor.ContainerPurposes.DISCARD:
			if verb: return "discard"
			else: return "your discard"

func mergeEffectSepecific(newEffect: CardEffect):
	assert(sourceOfCards == newEffect.sourceOfCards and destinationOfCards == newEffect.destinationOfCards and destinationOfUnchosenCards == newEffect.destinationOfUnchosenCards)
	amountOfCardsToChoose += newEffect.amountOfCardsToChoose
	amountOfCardsToChooseFrom += newEffect.amountOfCardsToChooseFrom

	