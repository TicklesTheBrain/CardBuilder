extends CardEffect
class_name ResourceModify

#TODO: currently only supports energy, need to add other types as well, like damage and so on.
enum modifyWhat {AMOUNT, RESET_ADJUST, BASELINE, RESET_BASELINE}
enum resourceList {ENERGY,TURN_START_CARD_DRAW}

@export var modifiedResource: resourceList
@export var modificationSubject: modifyWhat
@export var amountToModify = 1

func triggerSpecific(ctxt: GameStateContext):
	
	var resource
	if modifiedResource == resourceList.ENERGY:
		resource = ctxt.energyResource as GameResource
	elif modifiedResource == resourceList.TURN_START_CARD_DRAW:
		resource = ctxt.cardDraw as GameResource

	if modificationSubject == modifyWhat.AMOUNT:
		resource.amount += amountToModify
	elif modificationSubject == modifyWhat.RESET_ADJUST:
		resource.resetAdjust += amountToModify
	elif modificationSubject == modifyWhat.BASELINE:
		resource.baseline += amountToModify
	elif modificationSubject == modifyWhat.RESET_BASELINE:
		resource.resetBaseline += amountToModify

func getTextSpecific():
	return "Get {num} energy.".format({"num": amountToModify})

func mergeEffectSepecific(newEffect: CardEffect):
	assert(modifiedResource == newEffect.modifiedResource and modificationSubject == newEffect.modificationSubject)
	amountToModify += newEffect.amountToModify
	#TODO: should think about modifying to zero and effect no longer being needed. Maybe just text modification? Like overriding inherited getText()