extends Node
class_name CardPositionController

@export var cardMoveTime: float = 0.5
@export var logicalContainer: CardContainer
@export var canvasLayer: CanvasLayer

var cards: Array[CardDisplay] = []
var setupDone: bool = false

func _ready():
	if logicalContainer and not setupDone:
		setupNewLogicalContainer()
	InputLord.cardDragReleased.connect(_onCardDragReleased)

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
	removeCardDisplay(cardDisplay) #TODO: this is kinda ugly
	if canvasLayer:
		Events.orphanedCardDisplay.emit(cardDisplay)

func addCardDisplay(newCard: CardDisplay):
	
	newCard.positionController = self
	cards.push_back(newCard)
	scuttleCards()

func removeCardDisplay(cardToRemove: CardDisplay):
	if !cards.has(cardToRemove):
		return
	
	cards.erase(cardToRemove)
	scuttleCards()

func setupNewLogicalContainer(newContainer = null):
	if newContainer:
		logicalContainer = newContainer
	
	#for cases when controller is initiated later than the logical container
	for card in logicalContainer.getAll():
		addCardData(card)

	logicalContainer.cardAdded.connect(addCardData)
	logicalContainer.cardRemoved.connect(removeCardData)

	setupDone = true	

func scuttleCards():
	print("generic scuttle cards for position controller not overrriden")
	pass

func _onCardDragReleased(cardDisplay: CardDisplay):
	if cards.has(cardDisplay):
		scuttleCards()
