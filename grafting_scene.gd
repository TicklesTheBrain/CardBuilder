extends Node2D

@export var graftDeck: DeckManager
@export var playerDeck: DeckManager
@export var graftOptions: CardContainer
@export var graftDiscard: CardContainer
@export var cardGraftDisplay: PackedScene
@export var cardDisplay: PackedScene
@export var graftOptionsAmount: int = 3
@export var newCardMarker: Marker2D
@export var amountOfGraftsTodo: int = 3

var graftChoicePocket: CardContainer
var deckPocket: CardContainer
var selectedGraft: CardData
var selectedDeckCard: CardData

signal cardSelectionDone
signal deckPocketClosed
signal graftChoicePocketClosed

func _ready():
	
	Events.newCardDisplayRequested.connect(spawnNewCardDisplay)
	PocketLord.pocketClosed.connect(processPocketClosed)
	graftDeck.buildCardsFromTemplate()
	playerDeck.buildCardsFromTemplate()

	for g in range(amountOfGraftsTodo):


		PocketLord.requestNewPocket.emit("Choose 1 card graft", receivePocket, graftOptionsAmount)

		for i in range(graftOptionsAmount):
			addNewOption()

		InputLord.cardSelectionRequested.emit(graftChoicePocket, 1, receiveSelection)

		await cardSelectionDone

		graftChoicePocket.removeCard(selectedGraft)

		PocketLord.requestNewPocket.emit("Choose 1 to add graft to", receiveDeckPocket, playerDeck.getAll().size())

		playerDeck.disposeAll(deckPocket)

		InputLord.cardSelectionRequested.emit(deckPocket, 1, receiveDeckSelection)

		InputLord.mouseOvers = true
		InputLord.addMouseOverDelegate(deckPocket, askToShowGraft.bind(selectedGraft))

		await cardSelectionDone

		selectedDeckCard.addCardGraft(selectedGraft)

		deckPocket.disposeAll(playerDeck)
		graftChoicePocket.disposeAll(graftDiscard)

		selectedGraft.announceDestroy.emit()

		PocketLord.requestClosePocket.emit(graftChoicePocket)
		PocketLord.requestClosePocket.emit(deckPocket)

		#TODO: simplify destroying card displays when moving them to a container without a controller

		await deckPocketClosed



func processPocketClosed(cont: CardContainer):
	if cont == deckPocket:
		deckPocketClosed.emit()
	elif cont == graftChoicePocket:
		graftChoicePocketClosed.emit()


func receiveSelection(cards: Array[CardData]):
	selectedGraft = cards[0]
	cardSelectionDone.emit()

func askToShowGraft(card: CardDisplay, addExitDelegate: Callable,  graftToShow: CardData):
	card.showGraft(graftToShow)
	addExitDelegate.call(card, card.hideGraft)

func receiveDeckSelection(cards: Array[CardData]):
	selectedDeckCard = cards[0]
	cardSelectionDone.emit()

func receivePocket(cont: CardContainer):
	graftChoicePocket = cont

func receiveDeckPocket(cont: CardContainer):
	deckPocket = cont

func addNewOption():
	var topCard = graftDeck.drawCard()
	if topCard:		
		graftChoicePocket.addCard(topCard)

func spawnNewCardDisplay(card: CardData):

	var newCardDisplay
	if card.graft:
		newCardDisplay = cardGraftDisplay.instantiate() as CardGraftDisplay
	else:
		newCardDisplay = cardDisplay.instantiate() as CardDisplay

	newCardDisplay.setupCardDisplay(card)
	add_child(newCardDisplay)
	newCardDisplay.position = newCardMarker.position
	newCardDisplay.add_to_group("cd")
