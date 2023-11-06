extends PlayEffect
class_name ResourceModify

#TODO: currently only supports energy, need to add other types as well, like bust, damage and so on.

@export var amountToModify = 1

func triggerSpecific(ctxt: GameStateContext):
	ctxt.energyResource.amount += amountToModify


func getTextSpecific():
	return "Get {num} energy.".format({"num": amountToModify})
