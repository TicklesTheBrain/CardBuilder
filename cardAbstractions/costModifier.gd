extends CardModifier
class_name CostModifier

@export var capAtZero: bool = true

func calculateCost(ctxt: GameStateContext) -> int:
    if not active:
        return ctxt.modifiableValue
    var cost = calculateCost(ctxt)
    if capAtZero:
        return max(cost, 0)
    else:
        return cost

func calculateCostSpecific(ctxt: GameStateContext) -> int:
    print("this is a generic calculate cost function that was not overriden")
    return ctxt.modifiableValue
