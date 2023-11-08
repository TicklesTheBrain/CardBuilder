extends Conditional
class_name ConditionalAmount

@export var amountToMatchOrExceed: int
@export var disabledOnMatchOrExceed: bool = false

func getText():
    var text = "If no of cards played {verb} equal or more than {number}, "
    var verb = 'are'
    if disabledOnMatchOrExceed:
        verb = "aren't"
    return text.format({"verb": verb, "number": amountToMatchOrExceed})

func check(ctxt: GameStateContext):
    print('check amount triggered')
    var currAmount = ctxt.getContainerFromPurpose(containerToCheck).getAll().size()
    if not disabledOnMatchOrExceed and currAmount >= amountToMatchOrExceed:
        return true
    if disabledOnMatchOrExceed and currAmount < amountToMatchOrExceed:
        return true
    return false