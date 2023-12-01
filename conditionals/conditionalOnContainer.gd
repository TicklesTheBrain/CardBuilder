extends Conditional
class_name ConditionOnContainer

@export var amountToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false
@export var containerToCheck: Actor.ContainerPurposes

enum CheckType {TOTAL_VALUE, AMOUNT_OF_CARDS, AMOUNT_OF_TYPES, AMOUNT_OF_SINGLE_TYPE}
@export var cardTypeSubject: CardType.Types
@export var checkType: CheckType

func getTextSpecific():
	var what: String
	match checkType:
		CheckType.TOTAL_VALUE:
			what = "total value"
		CheckType.AMOUNT_OF_CARDS:
			what = "no of cards"
		CheckType.AMOUNT_OF_TYPES:
			what = "different types"
		CheckType.AMOUNT_OF_SINGLE_TYPE:
			what = "no of {symbol} cards".format({"symbol": CardType.Types.keys()[cardTypeSubject]})
			
	var where: String
	match containerToCheck:
		Actor.ContainerPurposes.DECK:
			where = "in deck"
		Actor.ContainerPurposes.HAND:
			where = "in hand"
		Actor.ContainerPurposes.PLAY_AREA:
			where = "played"
		Actor.ContainerPurposes.DISCARD:
			where = "discarded"

	var whatState = "is less" if disabledOnMatchOrExceed else "is more"
	var text = "If {what} {where} {whatState} than {number},"
	return text.format({"what": what, "where": where, "whatStat": whatState, "number": amountToMatchOrExceed})

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