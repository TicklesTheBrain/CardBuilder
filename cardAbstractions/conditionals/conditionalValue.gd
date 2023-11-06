extends Conditional
class_name ConditionalValue

@export var valueToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false

func getText():
    var text = "If value {verb} equal or more than {number}, "
    var verb = 'is'
    if disabledOnMatchOrExceed:
        verb = "isn't"
    return text.format({"verb": verb, "number": valueToMatchOrExceed})

func check(ctxt: GameStateContext):
    print('check triggered')
    var currPlayValue = ctxt.playArea.getTotalValue()
    if not disabledOnMatchOrExceed and currPlayValue >= valueToMatchOrExceed:
        return true
    if disabledOnMatchOrExceed and currPlayValue < valueToMatchOrExceed:
        return true
    return false