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
signal deckPocketClosed
signal graftChoicePocketClosed

func triggerSpecific(ctxt: GameStateContext):

	var actor = ctxt.getActorFromType(subjectActor)	 

	var graftCardArray = DeckManager.makeCardArrayFromTemplate(graftCardPackage.cards, debugOnly) as Array[CardData]
	graftCardArray.shuffle()
	PocketLord.pocketClosed.connect(processPocketClosed)
	
	for g in range(numberOfGrafts):

		PocketLord.requestNewPocket.emit("Choose 1 card graft", receivePocket, graftOptionsNo)

		assert(graftCardArray.size() >= graftOptionsNo)
		for i in range(graftOptionsNo):
			var graftOption = graftCardArray.pop_front()
			graftChoicePocket.addCard(graftOption)

		InputLord.cardSelectionRequested.emit(graftChoicePocket, 1, receiveSelection)

		await cardSelectionDone

		graftChoicePocket.removeCard(selectedGraft)
		selectedGraft.announceDestroy.emit()

		PocketLord.requestNewPocket.emit("Choose 1 to add graft to", receiveGraftOptionsPocket, cardOptions)
		
		var sourceCont = actor.getContainerFromPurpose(graftOptionsSource)
		for o in range(cardOptions):
			var newOption = sourceCont.drawCard()
			grafOptionsPocket.addCard(newOption)

		InputLord.cardSelectionRequested.emit(grafOptionsPocket, 1, receiveCardOptionSelection)

		InputLord.mouseOvers = true
		InputLord.addMouseOverDelegate(grafOptionsPocket, askToShowGraft.bind(selectedGraft))

		await cardSelectionDone

		selectedCardOption.addCardGraft(selectedGraft)
		grafOptionsPocket.disposeAll(sourceCont)
		sourceCont.shuffle()
		
		var unchosenGrafts = graftChoicePocket.getAll()
		for graft in unchosenGrafts:
			graft.announceDestroy.emit()

		InputLord.removeMouseOverDelegate(grafOptionsPocket)

		PocketLord.requestClosePocket.emit(graftChoicePocket)
		PocketLord.requestClosePocket.emit(grafOptionsPocket)

		#TODO: simplify destroying card displays when moving them to a container without a controller

		await deckPocketClosed


func processPocketClosed(cont: CardContainer):
	if cont == grafOptionsPocket:
		deckPocketClosed.emit()
	elif cont == graftChoicePocket:
		graftChoicePocketClosed.emit()

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
