extends Control
class_name Peaker

@export var logicalContainerToPeak: CardContainer
@export var sort: bool = true
@export var hideActual: bool = false

var pocketContainer: CardContainer

func _gui_input(event):
	# print('input event triggered', event)
	if event is InputEventMouseButton and event.is_pressed():
		InputLord.peakerClicked.emit(self)


func showPeak():

	if logicalContainerToPeak.getNoOfCards() < 1:
		print("cant peak empty container")
		return

	PocketLord.requestNewCardPocket.emit("", receivePocket, logicalContainerToPeak.getNoOfCards())

	var allCards = logicalContainerToPeak.getAll().map(func(c): return c.duplicate(true))
	
	if sort:
		allCards.sort_custom(cardSort)

	if hideActual:
		for card in logicalContainerToPeak.getAll():
			CardDisplayLord.getCardDisplay(card).visible = false
	
	for card in allCards:	
		pocketContainer.addCard(card)

	Events.confirmButtonEnable.emit()
	await Events.confirmButtonPressed
	Events.confirmButtonDisable.emit()

	if hideActual:
		for card in logicalContainerToPeak.getAll():
			CardDisplayLord.getCardDisplay(card).visible = true
	
	PocketLord.requestCloseCardPocket.emit(pocketContainer)

	
func cardSort(a: CardData,b: CardData):
	if a.type.type != b.type.type:
		return a.type.type > b.type.type
	return a.value.getBaseValue() > b.value.getBaseValue()
	
	
func receivePocket(newPocket: CardContainer):
	pocketContainer = newPocket


