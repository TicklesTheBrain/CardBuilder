extends Node

@export var cardDisplayPacked: PackedScene
@export var cardGraftPacked: PackedScene
@export var cardBackPacked: PackedScene
@export var defaultCardOrigin: Marker2D

signal orphanedCardDisplay(cd: CardDisplay)
signal newCardDisplayRequested(card: CardData)

func _ready():
	newCardDisplayRequested.connect(spawnNewCardDisplay)
	orphanedCardDisplay.connect(reparentCardDisplay)

func spawnNewCardDisplay(card: CardData):

	var newCardDisplay
	if card.graft:
		newCardDisplay = cardGraftPacked.instantiate() as CardGraftDisplay
	else:
		newCardDisplay = cardDisplayPacked.instantiate() as CardDisplay
	
	newCardDisplay.setupCardDisplay(card)
	add_child(newCardDisplay)
	#print('prev container origin ', card.prevContainer, card.prevContainer.originMarker)
	if card.prevContainer != null and card.prevContainer.originMarker !=null :
		newCardDisplay.position = card.prevContainer.originMarker.position
	else:
		newCardDisplay.position = defaultCardOrigin.position
	newCardDisplay.add_to_group("cd")

func reparentCardDisplay(cd: CardDisplay):

	cd.get_parent().remove_child(cd)
	add_child(cd)

func getCardDisplay(card: CardData):
	var cardDisplays = get_tree().get_nodes_in_group("cd")
	var matchingCD = cardDisplays.filter(func(cd): return cd.cardData == card)
	if matchingCD.size() == 0:
		return null
	else:
		return matchingCD[0]

func checkCardDisplayExists(card: CardData):
	return getCardDisplay(card) != null	