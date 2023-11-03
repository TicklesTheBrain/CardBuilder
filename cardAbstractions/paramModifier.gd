extends ContainerModifier
class_name ParamModifier

@export var type: CardParam.ParamType
@export var capAtZero: bool = true

func calculate(ctxt: GameStateContext, currValue: int, card: CardData) -> int:
    if not active:
        return currValue
    var cost = calculateSpecific(ctxt, currValue, card)
    if capAtZero:
        return max(cost, 0)
    else:
        return cost

func calculateSpecific(_ctxt: GameStateContext, currValue: int, _card: CardData) -> int:
    print("this is a generic calculate cost function that was not overriden")
    return currValue
