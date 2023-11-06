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

func addModifier(newMod: ParamModifier):
    modifiers.append(newMod)

func checkIsNonStatic():
    for mod in modifiers:
        if mod.active and mod.nonStatic:
            return true
    return false

func getNonStaticOptions():
    if checkIsNonStatic():
        for mod in modifiers:
            if mod.active and mod.nonStatic:
                return mod.options
    else:
        return []

