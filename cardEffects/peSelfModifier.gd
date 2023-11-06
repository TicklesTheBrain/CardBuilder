extends PlayEffect
class_name SelfModifier

@export var modifier: ParamModifier
@export var timingRules: Array[TC_Rule] = []

func triggerSpecific(ctxt: GameStateContext):
	print('card self apply modifier triggered ')
	var newMod = modifier.duplicate()
	for rule in timingRules:
		var newTC = rule.createNewTC(ctxt)
		newMod.addTC(newTC)

	match modifier.type:
		CardParam.ParamType.COST:
			ctxt.actingCard.cost.addModifier(newMod)
		CardParam.ParamType.VALUE:
			ctxt.actingCard.value.addModifier(newMod)