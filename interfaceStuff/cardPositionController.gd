extends Node
class_name CardPositionController

@export var cardMoveTime: float = 0.5
@export var logicalContainer: CardContainer
@export var canvasLayer: CanvasLayer
@export var canCreateNewDisplays: bool  = true
@export var resetRotation: bool = true
@export var resetRotationTo: float = 0
@export var reverseZ: bool = false

var interruptableTweens = {} #Tweens that can be interrupted if new interruptable or mandatory is made
var mandatoryTweens = {} #Tweens that cannot be interrupted unless cardDisplay is removed from controller

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
	updateCardZIndex()
	scuttleCards()

func removeCardDisplay(cardToRemove: CardDisplay):
	if !cards.has(cardToRemove):
		return
	
	cards.erase(cardToRemove)
	removeInterruptableTween(cardToRemove)
	removeMandatoryTween(cardToRemove)
	scuttleCards()

func setupNewLogicalContainer(newContainer = null):
	if newContainer:
		logicalContainer = newContainer
	
	#for cases when controller is initiated later than the logical container
	for card in logicalContainer.getAll():
		addCardData(card)

	logicalContainer.cardAdded.connect(addCardData)
	logicalContainer.cardRemoved.connect(removeCardData)
	logicalContainer.shuffled.connect(showShuffle)

	setupContainerSpecific()

	setupDone = true	

func scuttleCards():
	resetCardRotation()
	#stopPreviousTween()
	scuttleCardsSpecific()

func scuttleCardsSpecific():
	print("generic scuttle cards for position controller not overrriden")
	pass

func _onCardDragReleased(cardDisplay: CardDisplay):
	if cards.has(cardDisplay):
			scuttleCards()

func setupContainerSpecific():
	print("setup container specific not overriden, might be alright")

func resetCardRotation():
	if resetRotation:
		for card in cards:
			card.rotation_degrees = resetRotationTo

func showShuffle():
	updateCardZIndex()
	showShuffleSpecific()

func showShuffleSpecific():
	pass # Override by inheriting if needed

func updateCardZIndex():
	for cardDisplay in cards:
		var cardPosition = logicalContainer.getCardPosition(cardDisplay.cardData)
		if reverseZ:
			cardDisplay.setRegularZIndex(-cardPosition)
		else:
			cardDisplay.setRegularZIndex(cardPosition)

func addMandatoryTween(card: CardDisplay, tween: Tween):
	removeInterruptableTween(card)
	mandatoryTweens[card] = tween
	tween.finished.connect(removeMandatoryTween.bind(card))

func removeMandatoryTween(card: CardDisplay):
	if not mandatoryTweens.has(card):
		return
	mandatoryTweens[card].kill()
	mandatoryTweens.erase(card)

func addInterruptableTween(card: CardDisplay, tween: Tween):
	if mandatoryTweens.has(card):
		tween.kill()
	if interruptableTweens.has(card):
		interruptableTweens[card].kill()
		interruptableTweens.erase(card)

	interruptableTweens[card] = tween
	tween.finished.connect(removeInterruptableTween.bind(card))

func removeInterruptableTween(card: CardDisplay):
	if not interruptableTweens.has(card):
		return
	interruptableTweens[card].kill()
	interruptableTweens.erase(card)






