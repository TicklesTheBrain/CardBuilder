extends CostModifier
class_name ModifierCostFixed

@export var costShift: int = -1


func calculateCost(ctxt: GameStateContext):
    return ctxt.modifiableValue + costShift