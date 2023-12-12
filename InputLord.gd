extends Node

signal cardSelectionRequested(container: CardContainer, amount: int, receivingMethod: Callable)
signal cardSelectionComplete
signal cardClicked(display: CardDisplay)
signal cardDragReleased(display: CardDisplay)
signal cardMouseOver(display: CardDisplay)
signal cardMouseOverExit(display: CardDisplay)
signal mapPawnClicked(pawnClicked: MapPawn)
signal mapPawnDragReleased(pawnReleased: MapPawn)
signal itemClicked(item: ItemDisplay)
signal itemMouseOver(item: ItemDisplay)
signal itemMouseOverExit(item: ItemDisplay)


var mouseMonitoringGroups = ["cdc", "id", "bt"]
var mouseMonitorDictionary = {}

var selecting = false
var amount = -1
var subjectContainer: CardContainer
var selected: Array[CardData] = []
var dragging: bool = true
var dragContainers: Array[CardContainer] = []
var cardMouseOverDelegates: Dictionary
var cardMouseOverExitDelegates: Dictionary
var itemMouseOverDelegates: Dictionary
var itemMouseOverExitDelegates: Dictionary
var mouseOvers: bool = true
var itemsClickable: bool = true

func _ready():
	cardSelectionRequested.connect(initNewSelection)
	cardClicked.connect(_onCardClicked)
	cardDragReleased.connect(_onCardDragReleased)
	cardMouseOver.connect(_onCardMouseOver)
	cardMouseOverExit.connect(_onCardMouseOverExit)
	mapPawnClicked.connect(_onMapPawnClicked)
	mapPawnDragReleased.connect(_onMapPawnDragReleased)
	itemClicked.connect(_onItemClicked)
	itemMouseOver.connect(_onItemMouseOver)
	itemMouseOverExit.connect(_onItemMouseOverExit)


func disableOtherMouseMonitoring(exceptionNode):
	for groupname in mouseMonitoringGroups:
		for node in get_tree().get_nodes_in_group(groupname):
			if node == exceptionNode:
				continue

			if node is Control:
				mouseMonitorDictionary[node] = node.mouse_filter
				node.mouse_filter = Control.MOUSE_FILTER_IGNORE

func reenableMouseMonitoring():
	for node in mouseMonitorDictionary.keys():
		node.mouse_filter = mouseMonitorDictionary[node]

	mouseMonitorDictionary = {}


func _onMapPawnClicked(mapPawn: MapPawn):
	mapPawn.startDrag()

func _onMapPawnDragReleased(mapPawn: MapPawn):
	mapPawn.stopDrag()

func initNewSelection(container: CardContainer, needAmount: int, receivingMethod: Callable):
	print('init new selection', container)
	selecting = true
	selected = []
	subjectContainer = container
	amount = min(container.getAll().size(), needAmount)
	setupEndSelection(receivingMethod)
	if amount <= 0:
		cardSelectionComplete.emit()
	
func addToSelection(card: CardData):
	if selecting:
		selected.append(card)

	if selected.size() >= amount:
		cardSelectionComplete.emit()

func setupEndSelection(receivingMethod: Callable):
	await cardSelectionComplete
	selecting = false
	print('end selection triggered')
	receivingMethod.call(selected)

func removeFromSelection(card: CardData):
	if selected.has(card):
		selected.erase(card)

func addDragContainers(cont: CardContainer):
	dragContainers.push_back(cont)

func removeDragContainers(cont: CardContainer):
	dragContainers.erase(cont)

func checkCanDrag(card: CardData) -> bool:
	if not dragging:
		return false
	if card.container and dragContainers.has(card.container):
		return true
	return false

func _onCardClicked(display: CardDisplay):

	#If we need to select something, we check for select/unselect conditions
	if selecting:
		if selected.has(display.cardData):
			removeFromSelection(display.cardData)
			display.unselect()
			return
		elif display.cardData.container == subjectContainer:
			display.select()
			addToSelection(display.cardData)
			return
	
	#Next check if need to start a drag
	if checkCanDrag(display.cardData):
		display.get_parent().move_child(display, -1)
		display.startDrag()
		disableOtherMouseMonitoring(display.cardImageRect) #TODO: would be nicer to get this control cleaner
		#mouseOvers = false

func _onCardDragReleased(display: CardDisplay):
	display.endDrag()
	reenableMouseMonitoring()
	#mouseOvers = true

func _onCardMouseOver(display: CardDisplay):
	#print('card mouse entered', display)

	if not mouseOvers:
		return
	
	if cardMouseOverDelegates.has(display.cardData.container):
		cardMouseOverDelegates[display.cardData.container].call(display)

func _onCardMouseOverExit(display: CardDisplay):
	#print('card mouse left', display)
	if cardMouseOverExitDelegates.has(display):
		cardMouseOverExitDelegates[display].call()
		cardMouseOverExitDelegates.erase(display) #NOT SURE IF THIS IS NEEDED

func addCardMouseOverDelegate(cont: CardContainer, delegate: Callable):
	cardMouseOverDelegates[cont] = delegate.bind(addCardMouseOverExitDelegate)

func addCardMouseOverExitDelegate(card: CardDisplay, delegate: Callable):
	cardMouseOverExitDelegates[card] = delegate

func removeCardMouseOverDelegate(cont: CardContainer):
	cardMouseOverDelegates.erase(cont)

func _onItemMouseOver(display: ItemDisplay):
	#print('card mouse entered', display)

	if not mouseOvers:
		return
	
	if itemMouseOverDelegates.has(display.item.container):
		itemMouseOverDelegates[display.item.container].call(display)

func _onItemMouseOverExit(display: ItemDisplay):
	#print('card mouse left', display)
	if itemMouseOverExitDelegates.has(display):
		itemMouseOverExitDelegates[display].call()
		itemMouseOverExitDelegates.erase(display) #NOT SURE IF THIS IS NEEDED

func addItemMouseOverDelegate(cont: ItemContainer, delegate: Callable):
	itemMouseOverDelegates[cont] = delegate.bind(addItemMouseOverExitDelegate)

func addItemMouseOverExitDelegate(card: ItemDisplay, delegate: Callable):
	itemMouseOverExitDelegates[card] = delegate

func removeItemMouseOverDelegate(cont: ItemContainer):
	itemMouseOverDelegates.erase(cont)

func _onItemClicked(display: ItemDisplay):
	if itemsClickable:
		display.item.use()
