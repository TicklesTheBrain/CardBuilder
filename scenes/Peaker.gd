extends Control
class_name Peaker

@export var logicalContainerToPeak: CardContainer
@export var sort: bool = true

var pocketContainer: CardContainer

func _gui_input(event):
	# print('input event triggered', event)
	if event is InputEventMouseButton and event.is_pressed():
		InputLord.peakerClicked.emit(self)


func showPeak():
	PocketLord.requestNewCardPocket.emit("", receivePocket, logicalContainerToPeak.getAll().size())
	var allCards = logicalContainerToPeak.getAll().map(func(c): return c.duplicate(true))
	if sort:
		allCards.sort_custom(cardSort)
	for card in allCards:
		pocketContainer.addCard(card)
	Events.confirmButtonEnable.emit()
	await Events.confirmButtonPressed
	PocketLord.requestCloseCardPocket.emit(pocketContainer)

	
func cardSort(a: CardData,b: CardData):
	if a.type.type != b.type.type:
		return a.type.type > b.type.type
	return a.value.getBaseValue() > b.value.getBaseValue()
	
	
func receivePocket(newPocket: CardContainer):
	pocketContainer = newPocket


