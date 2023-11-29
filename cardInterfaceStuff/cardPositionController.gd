extends Node
class_name CardPositionController

@export var cardMoveTime: float = 0.5
@export var logicalContainer: CardContainer
@export var canvasLayer: CanvasLayer
@export var canCreateNewDisplays: bool  = true
@export var resetRotation: bool = true
@export var resetRotationTo: float = 0
@export var reverseZ: bool = false

var activeTween: Tween

var cards: Array[CardDisplay] = []
var setupDone: bool = false

func _ready():
	if logicalContainer and not setupDone:
		setupNewLogicalContainer()
	InputLord.cardDragReleased.connect(_onCardDragReleased)

func addCardData(cardData: CardData):

	if not CardDisplayLord.checkCardDisplayExists(cardData):
		if canCreateNewDisplays:
			CardDisplayLord.newCardDisplayRequested.emit(cardData)
		else:
			return
	
	var cardDisplay = CardDisplayLord.getCardDisplay(cardData)
	addCardDisplay(cardDisplay)
	if canvasLayer:
		#print('triggered add child')
		cardDisplay.get_parent().remove_child(cardDisplay)
		canvasLayer.add_child(cardDisplay)

func removeCardData(cardData: CardData):	
	
	if not CardDisplayLord.checkCardDisplayExists(cardData):
		return
	
	var cardDisplay = CardDisplayLord.getCardDisplay(cardData)
	removeCardDisplay(cardDisplay) #TODO: this is kinda ugly
	if canvasLayer:
		CardDisplayLord.orphanedCardDisplay.emit(cardDisplay)

func addCardDisplay(newCard: CardDisplay):
	
	newCard.positionController = self
	cards.push_back(newCard)
	if not reverseZ:
		newCard.z_index = cards.size()
	else:
		newCard.z_index = -cards.size()
	newCard.previousZOrder = cards.size() #TODO: this needs its own dedicated method, smells
	print(name, ' add card display triggered, new z_index ', newCard.z_index)
	stopPreviousTween()
	resetCardRotation()
	scuttleCards()

func removeCardDisplay(cardToRemove: CardDisplay):
	if !cards.has(cardToRemove):
		return
	
	cards.erase(cardToRemove)
	stopPreviousTween()
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
		stopPreviousTween()
		resetCardRotation()
		scuttleCards()

func setupContainerSpecific():
	print("setup container specific not overriden, might be alright")

func resetCardRotation():
	if resetRotation:
		for card in cards:
			card.rotation_degrees = resetRotationTo

		#print(name,' card rotation reset', cards.map(func(c): return c.rotation_degrees))

func stopPreviousTween():
	print(name, "stop previous tween called")
	if activeTween != null and activeTween.is_running():
		activeTween.kill()
		activeTween = null

