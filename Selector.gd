extends Node

signal cardSelectionRequested(container: CardContainer, amount: int, receivingMethod: Callable)
signal cardSelectionComplete
var selecting = false
var amount = -1
var subjectContainer: CardContainer
var selected: Array[CardData] = []

func _ready():
	cardSelectionRequested.connect(initNewSelection)

func initNewSelection(container: CardContainer, needAmount: int, receivingMethod: Callable):
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
	receivingMethod.call(selected)

func removeFromSelection(card: CardData):
	if selected.has(card):
		selected.erase(card)
