extends GameEffect
class_name GraftCard

@export var graftCardPackage: CardTemplatePackage
@export var graftOptionsNo: int
@export var cardOptions: int
@export var graftOptionsSource: Actor.ContainerPurposes
@export var numberOfGrafts: int = 1
@export var debugOnly: bool

var graftChoicePocket: CardContainer
var grafOptionsPocket: CardContainer
var selectedGraft: CardData
var selectedCardOption: CardData

signal cardSelectionDone
signal deckcardPocketClosed
signal graftChoicecardPocketClosed

func triggerSpecific(ctxt: GameStateContext):

	var actor = ctxt.getActorFromType(subjectActor)	 

	var graftCardArray = DeckManager.makeCardArrayFromTemplate(graftCardPackage.cards, debugOnly) as Array[CardData]
	graftCardArray.shuffle()
	PocketLord.cardPocketClosed.connect(processcardPocketClosed)
	
	for g in range(numberOfGrafts):

		PocketLord.requestNewCardPocket.emit("Choose 1 card graft", receivePocket, graftOptionsNo)

		assert(graftCardArray.size() >= graftOptionsNo)
		for i in range(graftOptionsNo):
			var graftOption = graftCardArray.pop_front()
			graftChoicePocket.addCard(graftOption)

		InputLord.cardSelectionRequested.emit(graftChoicePocket, 1, receiveSelection, true)

		await cardSelectionDone

		graftChoicePocket.removeCard(selectedGraft)
		selectedGraft.announceDestroy.emit()

		PocketLord.requestNewCardPocket.emit("Choose card to add this graft to", receiveGraftOptionsPocket, cardOptions)
		
		var sourceCont = actor.getContainerFromPurpose(graftOptionsSource)
		for o in range(cardOptions):
			var newOption = sourceCont.drawCard()
			grafOptionsPocket.addCard(newOption)

		InputLord.cardSelectionRequested.emit(grafOptionsPocket, 1, receiveCardOptionSelection, true)

		InputLord.mouseOvers = true
		InputLord.addCardMouseOverDelegate(grafOptionsPocket, askToShowGraft.bind(selectedGraft))

		await cardSelectionDone

		selectedCardOption.addCardGraft(selectedGraft)
		grafOptionsPocket.disposeAll(sourceCont)
		sourceCont.shuffle()
		
		var unchosenGrafts = graftChoicePocket.getAll()
		for graft in unchosenGrafts:
			graft.announceDestroy.emit()

		InputLord.removeCardMouseOverDelegate(grafOptionsPocket)

		PocketLord.requestCloseCardPocket.emit(graftChoicePocket)
		PocketLord.requestCloseCardPocket.emit(grafOptionsPocket)

		#TODO: simplify destroying card displays when moving them to a container without a controller

		await deckcardPocketClosed


func processcardPocketClosed(cont: CardContainer):
	if cont == grafOptionsPocket:
		deckcardPocketClosed.emit()
	elif cont == graftChoicePocket:
		graftChoicecardPocketClosed.emit()

func receiveSelection(cards: Array[CardData]):
	selectedGraft = cards[0]
	cardSelectionDone.emit()

func askToShowGraft(card: CardDisplay, addExitDelegate: Callable,  graftToShow: CardData):
	card.showGraft(graftToShow)
	card.showDetailed()
	addExitDelegate.call(card, closeShowGraft.bind(card))

func closeShowGraft(card: CardDisplay):
	card.hideGraft()
	card.hideDetailed()

func receiveCardOptionSelection(cards: Array[CardData]):
	selectedCardOption = cards[0]
	cardSelectionDone.emit()

func receivePocket(cont: CardContainer):
	graftChoicePocket = cont

func receiveGraftOptionsPocket(cont: CardContainer):
	grafOptionsPocket = cont
