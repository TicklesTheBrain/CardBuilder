extends Node
class_name CardPositionController

@export var cardMoveTime: float = 0.5
@export var logicalContainer: CardContainer
@export var canvasLayer: CanvasLayer
@export var canCreateNewDisplays: bool  = true

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
		if canCreateNewDisplays:
			CardDisplayLord.newCardDisplayRequested.emit(cardData)
		else:
			return
	cardDisplays = get_tree().get_nodes_in_group("cd")
	var cardDisplay = cardDisplays.filter(func(cd): return cd.cardData == cardData)[0]
	addCardDisplay(cardDisplay)
	if canvasLayer:
		#print('triggered add child')
		cardDisplay.get_parent().remove_child(cardDisplay)
		canvasLayer.add_child(cardDisplay)

func removeCardData(cardData: CardData):
	var cardDisplays = get_tree().get_nodes_in_group("cd")
	var matchingDisplays = cardDisplays.filter(func(cd): return cd.cardData == cardData)
	
	if matchingDisplays.size() == 0:
		return

	removeCardDisplay(matchingDisplays[0]) #TODO: this is kinda ugly
	if canvasLayer:
		CardDisplayLord.orphanedCardDisplay.emit(matchingDisplays[0])

func addCardDisplay(newCard: CardDisplay):
	
	newCard.positionController = self
	cards.push_back(newCard)
	newCard.z_index = cards.size()
	newCard.previousZOrder = cards.size() #TODO: this needs its own dedicated method, smells
	print(name, ' add card display triggered, new z_index ', newCard.z_index)
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

	setupContainerSpecific()

	setupDone = true	

func scuttleCards():
	print("generic scuttle cards for position controller not overrriden")
	pass

func _onCardDragReleased(cardDisplay: CardDisplay):
	if cards.has(cardDisplay):
		scuttleCards()

func setupContainerSpecific():
	print("setup container specific not overriden, might be alright")
