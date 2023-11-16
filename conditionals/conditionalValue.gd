extends Conditional
class_name ConditionalValue

@export var valueToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false

func getTextSpecific():
	var text = "If value {verb} equal or more than {number}, "
	var verb = 'is'
	if disabledOnMatchOrExceed:
		verb = "isn't"
	return text.format({"verb": verb, "number": valueToMatchOrExceed})

func check(ctxt: GameStateContext):
	print('check triggered')
	var currValue = ctxt.getContainerFromPurpose(containerToCheck).getTotalValue()
	if not disabledOnMatchOrExceed and currValue >= valueToMatchOrExceed:
		return true
	if disabledOnMatchOrExceed and currValue < valueToMatchOrExceed:
		return true
	return false
