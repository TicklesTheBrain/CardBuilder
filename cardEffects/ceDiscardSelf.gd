extends CardEffect
class_name DiscardSelf

@export var discardDesitnation: Game.ContainerPurposes = Game.ContainerPurposes.DISCARD

func triggerSpecific(ctxt: GameStateContext):

	var discardCont = ctxt.getContainerFromPurpose(discardDesitnation)
	var currCont = ctxt.actingCard.container
	currCont.disposeCard(ctxt.actingCard, discardCont)

func getTextSpecific() -> String:
	return "Immediately discard itself"

func mergeEffectSepecific(_newEffect: CardEffect):
	print("merging this does nothing", effectName)
