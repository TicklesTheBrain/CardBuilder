extends Resource
class_name CardParam

enum ParamType {COST, VALUE}

@export var baseValue: int = 0
@export var type: ParamType
@export var modifiers: Array[ParamModifier]
@export var staticText: String

func getValue(ctxt: GameStateContext, card: CardData):
    var value = card.container.applyModifiers(type, card, baseValue, ctxt)
    for mod in modifiers:
        value = mod.calculate(ctxt, value, card)
    return value

func getBaseValue():
    print('base value', baseValue)
    return baseValue

func getText():
    if staticText:
        return staticText
    var result = ""
    for mod in modifiers:
        result += mod.getText()
    return result

