extends CardEffect
class_name AddModifier

@export var containersToApply: Array[Actor.ContainerPurposes] = []
@export var modifier: Modifier
#TODO: Think about merging timingRules, could be fun
@export var timingRules: Array[TC_Rule] = []

func triggerSpecific(ctxt: GameStateContext):
	print('card apply modifier triggered ')

	var actor = ctxt.getActorFromType(subjectActor)

	for purpose in containersToApply:
		var newMod = modifier.duplicate()
		for rule in timingRules:
			var newTC = rule.createNewTC(ctxt)
			newMod.addTC(newTC)
		actor.getContainerFromPurpose(purpose).addModifier(newMod)

func mergeEffectSpecific(newEffect: CardEffect):
	assert(containersToApply.hash() == newEffect.containersToApply.hash())
	modifier.mergeModifier(newEffect.modifier)