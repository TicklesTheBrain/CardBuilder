extends ParamModifier
class_name ModifierFixedChange

@export var shift: int = -1

func calculateSpecific(_ctxt: GameStateContext, currValue: int, _card: CardData):
    return currValue + shift