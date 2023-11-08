extends Node2D
class_name VariedPositionController

@export var posCollections: Array[Node2D]
@export var cardMoveTime: float = 0.5
@export var canvasLayer: CanvasLayer

var cards: Array[CardDisplay] = []
var setupDone: bool = false
@export var logicalContainer: CardContainer

func _ready():
	if logicalContainer and not setupDone:
		setupNewLogicalContainer()
	

func addCardData(cardData: CardData):
	var cardDisplays = get_tree().get_nodes_in_group("cd")
	var matchingCD = cardDisplays.filter(func(cd): return cd.cardData == cardData)
	if matchingCD.size() == 0:
		Events.newCardDisplayRequested.emit(cardData)
	cardDisplays = get_tree().get_nodes_in_group("cd")
	var cardDisplay = cardDisplays.filter(func(cd): return cd.cardData == cardData)[0]
	addCardDisplay(cardDisplay)
	if canvasLayer:
		#print('triggered add child')
		cardDisplay.get_parent().remove_child(cardDisplay)
		canvasLayer.add_child(cardDisplay)

func removeCardData(cardData: CardData):
	var cardDisplays = get_tree().get_nodes_in_group("cd")
	var cardDisplay = cardDisplays.filter(func(cd): return cd.cardData == cardData)[0]
	removeCardDisplay(cardDisplay)
	if canvasLayer:
		Events.orphanedCardDisplay.emit(cardDisplay)


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

func setupNewLogicalContainer(newContainer = null):
	if newContainer:
		logicalContainer = newContainer
	
	#for cases when controller is initiated later than the logical container
	for card in logicalContainer.getAll():
		addCardData(card)

	logicalContainer.cardAdded.connect(addCardData)
	logicalContainer.cardRemoved.connect(removeCardData)

	setupDone = true

