extends GameEffect
class_name DrawCards

@export var source: Actor.ContainerPurposes = Actor.ContainerPurposes.DECK
@export var destination: Actor.ContainerPurposes = Actor.ContainerPurposes.HAND
@export var amountOfCardsToDraw: int = 1

func triggerSpecific(ctxt: GameStateContext):
	print('card draw triggered')
	var actor = ctxt.getActorFromType(subjectActor)	

	var s = actor.getContainerFromPurpose(source)
	var d = actor.getContainerFromPurpose(destination)

	for i in range(amountOfCardsToDraw):
		if d.checkFull():
			return
		var newCard = s.drawCard()
		if newCard:
			d.addCard(newCard)
		else:
			return

func getTextSpecific() -> String:
	return "Draw {num} card".format({"num": amountOfCardsToDraw})

func mergeEffectSepecific(newEffect: GameEffect):
	assert(source == newEffect.source and destination == newEffect.destination)
	amountOfCardsToDraw += newEffect.amountOfCardsToDraw
	
