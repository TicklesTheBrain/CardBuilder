extends Node
class_name ContainerCounter

@export var cardContainer: CardContainer
@export var startingValue: int = 0
@export var bustValue: int = 21
@export var label: Label

enum countWhat {VALUE, AMOUNT}
@export var countSubject: countWhat

var count = -1
var prevCount = count

signal countChanged(newValue)

func _ready():
	if cardContainer == null:
		cardContainer = get_parent() as CardContainer
	
	cardContainer.cardAdded.connect(recalculateValue)
	cardContainer.cardRemoved.connect(recalculateValue)

	if label != null:
		countChanged.connect(updateLabel)

	recalculateValue()

func recalculateValue(_discardedValue = null):	
	match countSubject:
		countWhat.VALUE:
			count = cardContainer.cards.reduce(func(acc, card): return acc+card.getValue(), startingValue)
		countWhat.AMOUNT:
			count = cardContainer.cards.size()

	if count != prevCount:
		countChanged.emit(count)
		prevCount = count

func updateLabel(newValue):
	label.text = str(newValue)

func checkIsBusted() -> bool:
	var currBustValue = cardContainer.getModifiedBustValue(bustValue)
	return bustValue > 0 and prevCount > currBustValue
