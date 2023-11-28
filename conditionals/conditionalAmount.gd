extends Conditional
class_name ConditionalAmount

@export var amountToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false

func getTextSpecific():
	var text = "If no of cards played {verb} equal or more than {number}, "
	var verb = 'are'
	if disabledOnMatchOrExceed:
		verb = "aren't"
	return text.format({"verb": verb, "number": amountToMatchOrExceed})

func check(ctxt: GameStateContext):

	print('check amount triggered')
	var actor = ctxt.getActorFromType(subjectActor)
	var currAmount = actor.getContainerFromPurpose(containerToCheck).getAll().size()
	if not disabledOnMatchOrExceed and currAmount >= amountToMatchOrExceed:
		return true
	if disabledOnMatchOrExceed and currAmount < amountToMatchOrExceed:
		return true
	return false

func mergeConditionalSpecific(newConditional: Conditional):
	assert(disabledOnMatchOrExceed == newConditional.disabledOnMatchOrExceed)
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
