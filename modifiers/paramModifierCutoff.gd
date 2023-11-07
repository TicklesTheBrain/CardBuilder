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
	