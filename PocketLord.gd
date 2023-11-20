extends Node

@export var pocketPacked: PackedScene
var pocketRefs = {}

func _ready():
	Events.requestNewPocket.connect(makeNewPocket)
	Events.requestClosePocket.connect(cleanUpPocket)

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
	cardContainer.queue_free()
	pocketRefs.erase(cardContainer)