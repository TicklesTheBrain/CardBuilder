extends Node

@export var cardPocketPacked: PackedScene
@export var itemPocketPacked: PackedScene

var pocketRefs = {}

signal requestNewCardPocket(pocketText: String, receivingMethod: Callable, expectedCards: int)
signal requestCloseCardPocket(pocketID: CardContainer)
signal cardPocketClosed(cont: CardContainer)
signal itemPocketClosed(cont: ItemContainer)
signal requestNewItemPocket(pocketText: String, receivingMethod: Callable)
signal requestCloseItemPocket(pocketID: ItemContainer)


func _ready():
	requestNewCardPocket.connect(makeNewCardPocket)
	requestCloseCardPocket.connect(cleanUpCardPocket)
	requestNewItemPocket.connect(makeNewItemPocket)
	requestCloseItemPocket.connect(cleanUpItemPocket)

func makeNewCardPocket(pocketText: String, receivingMethod: Callable, expectedCards: int, confirmationButton: bool = false):	

	var newPocket = cardPocketPacked.instantiate() as CardPocketDisplay
	newPocket.okButton.visible = confirmationButton
	add_child(newPocket)
	newPocket.setSize(expectedCards)
	var pocketContainer = newPocket.pocketContainer
	newPocket.setupText(pocketText)

	newPocket.layer += pocketRefs.keys().size() #new pockets always open on top

	pocketRefs[pocketContainer] = newPocket
	newPocket.showPocket()
	receivingMethod.call(pocketContainer)

func cleanUpCardPocket(cardContainer: CardContainer):
	
	Logger.log(['cleanup pocket started', cardContainer], 3)
	var pocket = pocketRefs[cardContainer]
	pocket.hidePocket()
	await pocket.cardPocketClosed
	cardPocketClosed.emit(cardContainer)
	cardContainer.queue_free()
	pocketRefs.erase(cardContainer)

func makeNewItemPocket(pocketText: String, receivingMethod: Callable):
	var newPocket = itemPocketPacked.instantiate() as ItemPocketDisplay
	add_child(newPocket)
	var pocketContainer = newPocket.pocketContainer
	newPocket.setupText(pocketText)

	newPocket.layer += pocketRefs.keys().size()

	pocketRefs[pocketContainer] = newPocket
	newPocket.showPocket()
	receivingMethod.call(pocketContainer)

func cleanUpItemPocket(container: ItemContainer):

	Logger.log(['cleanup item pocket started', ItemContainer], 3)
	var pocket = pocketRefs[container]
	pocket.hidePocket()
	await pocket.itemPocketClose
	itemPocketClosed.emit(container)
	container.queue_free()
	pocketRefs.erase(container)
