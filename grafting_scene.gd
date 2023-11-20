extends Node2D

@export var graftDeck: DeckManager
@export var playerDeck: DeckManager
@export var graftOptions: CardContainer
@export var cardGraftDisplay: PackedScene
@export var cardDisplay: PackedScene
@export var graftOptionsAmount: int = 3
@export var newCardMarker: Marker2D

var graftChoicePocket: CardContainer
var deckPocket: CardContainer
var selectedGraft: CardData
var selectedDeckCard: CardData

signal cardSelectionDone

func _ready():
	Events.newCardDisplayRequested.connect(spawnNewCardDisplay)
	graftDeck.buildCardsFromTemplate()
	playerDeck.buildCardsFromTemplate()

	Events.requestNewPocket.emit("Choose 1 card graft", receivePocket)

	for i in range(graftOptionsAmount):
		addNewOption()

	InputLord.cardSelectionRequested.emit(graftChoicePocket, 1, receiveSelection)

	await cardSelectionDone

	Events.requestNewPocket.emit("Choose 1 to add graft to", receiveDeckPocket)

	playerDeck.disposeAll(deckPocket)

	InputLord.cardSelectionRequested.emit(deckPocket, 1, receiveDeckSelection)

	InputLord.mouseOvers = true
	InputLord.addMouseOverDelegate(deckPocket, askToShowGraft.bind(selectedGraft))

	await cardSelectionDone

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
