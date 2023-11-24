extends Resource
class_name CardParam

enum ParamType {COST, VALUE, ATTACK, DEFENCE}

@export var baseValue: int = 0:
	set(val):
		if capAtZero:
			baseValue = max(0, val)
		else:
			baseValue = val
@export var type: ParamType
@export var modifiers: Array[ParamModifier]
@export var staticText: String
@export var capAtZero: bool = false

func getValue(ctxt: GameStateContext, card: CardData):
	var value: int
	if not card.container:
		value = baseValue 
	else:
		value = card.container.applyModifiers(type, card, baseValue, ctxt)
	for mod in modifiers:
		value = mod.calculate(ctxt, value, card)
	return value if not capAtZero else max(value, 0)

func getBaseValue():
	#print('base value', baseValue)
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
	return modifiers.any(func(m): return m.active and "nonStatic" in m and m.nonStatic)

func getNonStaticOptions():
	if checkIsNonStatic():
		for mod in modifiers:
			if mod.active and "nonStatic" in mod and mod.nonStatic:
				return mod.options
	else:
		return []

func mergeCardParam(newCardParam: CardParam):
	assert (type == newCardParam.type)
	capAtZero = capAtZero or newCardParam.capAtZero
	baseValue += newCardParam.baseValue
	CardData.mergeModifiersBuckets(modifiers as Array[Modifier], newCardParam.modifiers as Array[Modifier]) #TODO: this is ugly


