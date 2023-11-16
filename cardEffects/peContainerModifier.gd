extends CardEffect
class_name AddModifier

@export var containersToApply: Array[Game.ContainerPurposes] = []
@export var modifier: Modifier
@export var timingRules: Array[TC_Rule] = []

func triggerSpecific(ctxt: GameStateContext):
	print('card apply modifier triggered ')

	for purpose in containersToApply:
		var newMod = modifier.duplicate()
		for rule in timingRules:
			var newTC = rule.createNewTC(ctxt)
			newMod.addTC(newTC)
		ctxt.getContainerFromPurpose(purpose).addModifier(newMod)