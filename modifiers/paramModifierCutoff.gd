extends ParamModifier
class_name ModifierCutoff

@export var amountForCutOff: int = 4
@export var cutoffBelow: bool = true #if false cutsoff above
@export var onCutOffReturn: int = 0
@export var cutoffBasedOnParamItself: bool = true
@export var cutoffCriteriaParam: CardParam.ParamType

#TODO: FIGURE OUT HOW THIS INTERACTS WITH CHOOSE BEST

func calculateSpecific(_ctxt: GameStateContext, currValue: int, card: CardData):
	var criteria = currValue
	if not cutoffBasedOnParamItself:
		match cutoffCriteriaParam:
			CardParam.ParamType.COST:
				criteria = card.cost.getBaseValue()
			CardParam.ParamType.VALUE:
				criteria = card.value.getBaseValue()
	if cutoffBelow and criteria <= amountForCutOff:
		return onCutOffReturn
	if not cutoffBelow and criteria >= amountForCutOff:
		return onCutOffReturn
	return currValue

func mergeModifierSpecific(newModifier: Modifier):
	assert(cutoffBelow == newModifier.cutoffBellow)
	assert(onCutOffReturn == newModifier.onCutOffReturn)
	assert(cutoffBasedOnParamItself == newModifier.cutoffBasedOnParamItself)
	if not cutoffBasedOnParamItself:
		assert(cutoffCriteriaParam == newModifier.cutoffCriteriaParam)
	
	if amountForCutOff == newModifier.amountForCutOff:
		if cutoffBelow:
			amountForCutOff = max(0, amountForCutOff-1)
		else:
			amountForCutOff += 1
	else:
		if cutoffBelow:
			amountForCutOff = min(amountForCutOff, newModifier.amountForCutOff)
		else:
			amountForCutOff = max(amountForCutOff, newModifier.amountForCutOff)

	