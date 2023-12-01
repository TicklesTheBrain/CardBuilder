extends Node

@export var pocketPacked: PackedScene

var pocketRefs = {}

signal requestNewPocket(pocketText: String, receivingMethod: Callable, expectedCards: int)
signal requestClosePocket(pocketID: CardContainer)
signal pocketClosed(cont: CardContainer)

func _ready():
	requestNewPocket.connect(makeNewPocket)
	requestClosePocket.connect(cleanUpPocket)

func makeNewPocket(pocketText: String, receivingMethod: Callable, expectedCards: int):	

	var newPocket = pocketPacked.instantiate() as PocketDisplay
	newPocket.setSize(expectedCards)
	var pocketContainer = newPocket.pocketContainer
	newPocket.setupText(pocketText)
	add_child(newPocket)

	newPocket.layer += pocketRefs.keys().size() #new pockets always open on top

	pocketRefs[pocketContainer] = newPocket
	newPocket.showPocket()
	receivingMethod.call(pocketContainer)

func cleanUpPocket(cardContainer: CardContainer):
	
	Logger.log(['cleanup pocket started', cardContainer], 3)
	var pocket = pocketRefs[cardContainer]
	pocket.hidePocket()
	await pocket.pocketClosed
	pocketClosed.emit(cardContainer)
	cardContainer.queue_free()
	pocketRefs.erase(cardContainer)