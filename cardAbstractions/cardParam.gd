extends Resource
class_name CardParam

enum ParamType {COST, VALUE}

@export var ogValue: int = 0
@export var type: ParamType

func getValue(ctxt: GameStateContext, card: CardData):
    var containerModified = card.container.applyModifiers(type, card, ogValue, ctxt)
    return containerModified

