extends GameEffect
class_name ResourceModify

@export var modifiedResource: Actor.GameResources
@export var resourcePropety: GameResource.Properties
@export var amountToModify = 1

func triggerSpecific(ctxt: GameStateContext):

	var actor = ctxt.getActorFromType(subjectActor)	 
	
	var resource = actor.getResourceFromEnum(modifiedResource)
	resource.shiftProperty(resourcePropety, amountToModify)
	

func getTextSpecific():
	return "Get {num} energy.".format({"num": amountToModify})

func mergeEffectSepecific(newEffect: GameEffect):
	assert(modifiedResource == newEffect.modifiedResource and resourcePropety == newEffect.resourcePropety)
	amountToModify += newEffect.amountToModify
	#TODO: should think about modifying to zero and effect no longer being needed. Maybe just text modification? Like overriding inherited getText()
