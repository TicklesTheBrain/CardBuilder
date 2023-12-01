extends Conditional
class_name ConditionOnContainer

@export var amountToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false
@export var containerToCheck: Actor.ContainerPurposes

enum CheckType {TOTAL_VALUE, AMOUNT_OF_CARDS, AMOUNT_OF_TYPES, AMOUNT_OF_SINGLE_TYPE}
@export var cardTypeSubject: CardType.Types
@export var checkType: CheckType

func getTextSpecific():
	var text = "If no of cards played {verb} equal or more than {number}, "
	var verb = 'are'
	if disabledOnMatchOrExceed:
		verb = "aren't"
	return text.format({"verb": verb, "number": amountToMatchOrExceed})

func check(ctxt: GameStateContext):

	print('check amount triggered')
	var actor = ctxt.getActorFromType(subjectActor)
	var container = actor.getContainerFromPurpose(containerToCheck)

	var amount
	match checkType:
		CheckType.TOTAL_VALUE:
			amount = container.getTotalValue()
		CheckType.AMOUNT_OF_CARDS:
			amount = container.getNoOfCards()
		CheckType.AMOUNT_OF_TYPES:			
			var typeDict = {}
			for card in container.getAll():
				typeDict[card.type.type] = ""
			amount = typeDict.keys().size()
		CheckType.AMOUNT_OF_SINGLE_TYPE:
			var allTypes = container.getAll().map(func(c): return c.type.type)
			amount = allTypes.count(cardTypeSubject)
	
	if not disabledOnMatchOrExceed and amount >= amountToMatchOrExceed:
		return true
	if disabledOnMatchOrExceed and amount < amountToMatchOrExceed:
		return true
	return false

func mergeConditionalSpecific(newConditional: Conditional):
	assert(containerToCheck == newConditional.containerToCheck)
	assert(disabledOnMatchOrExceed == newConditional.disabledOnMatchOrExceed)
	assert(checkType == newConditional.checkType)

	if disabledOnMatchOrExceed:
		if amountToMatchOrExceed == newConditional.amountToMatchOrExceed:
			amountToMatchOrExceed -= 1
		else:
			amountToMatchOrExceed += 1

	else:
		if disabledOnMatchOrExceed:
			amountToMatchOrExceed =  min(amountToMatchOrExceed, newConditional.amountToMatchOrExceed)
		else:
			amountToMatchOrExceed =  max(amountToMatchOrExceed, newConditional.amountToMatchOrExceed)