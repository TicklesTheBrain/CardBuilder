extends CardEffect
class_name ResourceModify

#TODO: currently only supports energy, need to add other types as well, like damage and so on.
enum modifyWhat {AMOUNT, RESET_ADJUST, BASELINE}
enum resourceList {ENERGY,TURN_START_CARD_DRAW}

@export var modifiedResource: resourceList
@export var modificationSubject: modifyWhat
@export var amountToModify = 1

func triggerSpecific(ctxt: GameStateContext):
	
	var resource
	if modifiedResource == resourceList.ENERGY:
		resource = ctxt.energyResource as GenericResource
	elif modifiedResource == resourceList.TURN_START_CARD_DRAW:
		resource = ctxt.cardDraw as GenericResource

	if modificationSubject == modifyWhat.AMOUNT:
		resource.amount += amountToModify
	elif modificationSubject == modifyWhat.RESET_ADJUST:
		resource.resetAdjust += amountToModify
	elif modificationSubject == modifyWhat.BASELINE:
		resource.baseline += amountToModify
	


func getTextSpecific():
	return "Get {num} energy.".format({"num": amountToModify})
