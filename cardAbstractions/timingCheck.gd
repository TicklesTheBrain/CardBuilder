extends Resource
class_name TimingCheck

enum CheckType {ACTIVATOR, DEACTIVATOR}

var type: CheckType
var turnOn: bool = false
var turnOff: bool = false
var counter: int = -1

var subjectCard: CardData
var containerSubject: CardContainer

func decreaseCounter(_discardValue = null, _discardValue2 = null):
	counter -= 1
	if counter == 0:
		match type:
			CheckType.ACTIVATOR:
				turnOn = true
			CheckType.DEACTIVATOR:
				turnOff = true

func counterDecreaseOnCardPlayed(container: CardContainer, card: CardData):
	if container != containerSubject:
		return
	if subjectCard and card == subjectCard:
		return
	decreaseCounter()

func counterDecreaseOnCardRemoved(_container: CardContainer, card: CardData):
	if subjectCard != card:
		return
	if card.prevContainer and card.prevContainer == containerSubject:
		decreaseCounter()

func connectCardPlayed():
	Events.cardAdded.connect(counterDecreaseOnCardPlayed)

func connectTurnEnd():
	Events.playerTurnEnd.connect(decreaseCounter)

func connectTurnStart():
	Events.playerTurnStart.connect(decreaseCounter)

func connectCardRemoved():
	Events.cardAdded.connect(counterDecreaseOnCardRemoved)
