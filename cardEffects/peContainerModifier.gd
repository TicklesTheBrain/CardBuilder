extends PlayEffect
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
		addModifier(purpose, newMod, ctxt)

func addModifier(purpose: Game.ContainerPurposes, newMod: Modifier, ctxt: GameStateContext):
	match purpose:
		Game.ContainerPurposes.HAND:
			ctxt.hand.addModifier(newMod)
		Game.ContainerPurposes.DISCARD:
			ctxt.discard.addModifier(newMod)
		Game.ContainerPurposes.PLAY_AREA:
			ctxt.playArea.addModifier(newMod)
		Game.ContainerPurposes.DECK:
			ctxt.drawDeck.addModifier(newMod)

