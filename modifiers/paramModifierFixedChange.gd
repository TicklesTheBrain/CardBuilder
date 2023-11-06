extends ParamModifier
class_name ModifierFixedChange

@export var shift: int = -1

func calculateSpecific(_ctxt: GameStateContext, currValue: int, _card: CardData):
    #print('calculate specific called', currValue, shift)
    return currValue + shift