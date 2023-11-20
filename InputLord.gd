extends Node

signal cardSelectionRequested(container: CardContainer, amount: int, receivingMethod: Callable)
signal cardSelectionComplete
signal cardClicked(display: CardDisplay)
signal cardDragReleased(display: CardDisplay)

var selecting = false
var amount = -1
var subjectContainer: CardContainer
var selected: Array[CardData] = []
var dragging: bool = true
var dragContainers: Array[CardContainer] = []
var mouseOverDelegates: Dictionary
var mouseOvers: bool = true

func _ready():
	cardSelectionRequested.connect(initNewSelection)
	cardClicked.connect(_onCardClicked)
	cardDragReleased.connect(_onCardDragReleased)

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
		display.startDrag()

func _onCardDragReleased(display: CardDisplay):
	display.endDrag()




