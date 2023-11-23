extends CardEffect
class_name DrawCards

@export var source: Actor.ContainerPurposes = Actor.ContainerPurposes.DECK
@export var destination: Actor.ContainerPurposes = Actor.ContainerPurposes.HAND
@export var amountOfCardsToDraw: int = 1

func triggerSpecific(ctxt: GameStateContext):
	print('card draw triggered')

	var s = ctxt.getContainerFromPurpose(source)
	var d = ctxt.getContainerFromPurpose(destination)

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

func mergeEffectSepecific(newEffect: CardEffect):
	assert(source == newEffect.source and destination == newEffect.destination)
	amountOfCardsToDraw += newEffect.amountOfCardsToDraw
	
