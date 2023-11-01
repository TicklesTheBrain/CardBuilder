extends Node2D
class_name VariedPositionController

@export var posCollections: Array[Node2D]
@export var cardMoveTime: float = 0.5
var cards: Array[CardDisplay] = []
@export var logicalContainer: CardContainer

func _ready():
	logicalContainer.cardAdded.connect(addedToHand)
	logicalContainer.cardRemoved.connect(removedFromHand)

func addedToHand(cardData: CardData):
	var cardDisplays = get_tree().get_nodes_in_group("cd")
	var matchingCD = cardDisplays.filter(func(cd): return cd.cardData == cardData)
	if matchingCD.size() == 0:
		Events.newCardDisplayRequested.emit(cardData)
	cardDisplays = get_tree().get_nodes_in_group("cd")
	addCardDisplay(cardDisplays.filter(func(cd): return cd.cardData == cardData)[0])

func removedFromHand(cardData: CardData):
	var cardDisplays = get_tree().get_nodes_in_group("cd")
	removeCardDisplay(cardDisplays.filter(func(cd): return cd.cardData == cardData)[0])

func addCardDisplay(newCard: CardDisplay):

	if cards.size() >= posCollections.size():
		return
	
	newCard.positionController = self
	cards.push_back(newCard)
	scuttleCards()

func removeCardDisplay(cardToRemove: CardDisplay):
	if !cards.has(cardToRemove):
		return
	
	cards.erase(cardToRemove)
	scuttleCards()

func scuttleCards():

	if cards.size() < 1:
		return

	var i = 0
	var currentCollection = posCollections[cards.size()-1].get_children()
	var tween = get_tree().create_tween().set_parallel()

	for card: CardDisplay in cards:
		var newMarker = currentCollection[i]
		i +=1
		tween.tween_property(card,"position", newMarker.position, cardMoveTime)



