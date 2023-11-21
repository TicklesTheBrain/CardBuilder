extends Node

@export var pocketPacked: PackedScene
var pocketRefs = {}

signal requestNewPocket(pocketText: String, receivingMethod: Callable)
signal requestClosePocket(pocketID: CardContainer)
signal pocketClosed(cont: CardContainer)

func _ready():
	requestNewPocket.connect(makeNewPocket)
	requestClosePocket.connect(cleanUpPocket)

func makeNewPocket(pocketText: String, receivingMethod: Callable):

	var newPocket = pocketPacked.instantiate() as PocketDisplay
	var pocketContainer = CardContainer.new()
	add_child(pocketContainer)
	newPocket.setupPositionController(pocketContainer)
	newPocket.setupText(pocketText)
	add_child(newPocket)

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