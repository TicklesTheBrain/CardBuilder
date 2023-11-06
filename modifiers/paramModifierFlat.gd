extends ParamModifier
class_name ModifierFlathange

@export var flatChange: int = -1

func calculateSpecific(_ctxt: GameStateContext, _currValue: int, _card: CardData):
    #print('calculate specific called', currValue, shift)
    return flatChange