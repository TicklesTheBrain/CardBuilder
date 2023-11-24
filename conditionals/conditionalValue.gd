extends Conditional
class_name ConditionalValue

@export var valueToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false

#TODO: value and amount should just be flags rather than separate classes

func getTextSpecific():
	var text = "If value {verb} equal or more than {number}, "
	var verb = 'is'
	if disabledOnMatchOrExceed:
		verb = "isn't"
	return text.format({"verb": verb, "number": valueToMatchOrExceed})

func check(ctxt: GameStateContext):
	print('conditional value check triggered')
	var actor = ctxt.getActorFromType(subjectActor)
	var currValue = actor.getContainerFromPurpose(containerToCheck).getTotalValue()
	if not disabledOnMatchOrExceed and currValue >= valueToMatchOrExceed:
		return true
	if disabledOnMatchOrExceed and currValue < valueToMatchOrExceed:
		return true
	return false

func mergeConditionalSpecific(newConditional: Conditional):
	assert(disabledOnMatchOrExceed == newConditional.disabledOnMatchOrExceed)
	if disabledOnMatchOrExceed:
		if valueToMatchOrExceed == newConditional.valueToMatchOrExceed:
			valueToMatchOrExceed -= 1
		else:
			valueToMatchOrExceed += 1

	else:
		if disabledOnMatchOrExceed:
			valueToMatchOrExceed =  min(valueToMatchOrExceed, newConditional.valueToMatchOrExceed)
		else:
			valueToMatchOrExceed =  max(valueToMatchOrExceed, newConditional.valueToMatchOrExceed)
