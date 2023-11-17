extends Node2D

@export var graftDeck: DeckManager
@export var playerDeck: DeckManager
@export var graftOptions: CardContainer
@export var cardGraftDisplay: PackedScene
@export var cardDisplay: PackedScene
@export var graftOptionsAmount: int = 3
@export var newCardMarker: Marker2D

func _ready():
	graftDeck.buildCardsFromTemplate()
	#playerDeck.buildCardsFromTemplate()
	Events.newCardDisplayRequested.connect(spawnNewCardDisplay)
	for i in range(graftOptionsAmount):
		addNewOption()

func addNewOption():
	var topCard = graftDeck.drawCard()
	if topCard:		
		graftOptions.addCard(topCard)

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
