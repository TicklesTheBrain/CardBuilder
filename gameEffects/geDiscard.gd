extends GameEffect
class_name DiscardCards

@export var amountOfCardsToDiscard: int = 1
@export var discardFrom: Actor.ContainerPurposes
@export var askToConfirm: bool = true

var selectedCards: Array[CardData] = []
signal cardSelectionDone

func triggerSpecific(ctxt: GameStateContext):

	print('card discard triggered')

	var actor = ctxt.getActorFromType(subjectActor)
	var cont = actor.getContainerFromPurpose(discardFrom)

	if amountOfCardsToDiscard == -1:
		cont.disposeAll()
	else:
		var clampedAmount = min(cont.getNoOfCards(), amountOfCardsToDiscard)
		if clampedAmount > 0:
			Events.newTopMessageRequested.emit("Choose {num} cards to discard".format({"num": clampedAmount}))
			InputLord.cardSelectionRequested.emit(actor.hand, clampedAmount, receiveSelection, askToConfirm)
			await cardSelectionDone
			Events.hideTopMessages.emit()
			for card in selectedCards:
				cont.disposeCard(card)
		else:
			print("nothing to discard")

func getTextSpecific() -> String:
	if amountOfCardsToDiscard == -1:
		return "discard all cards."
	else:
		return "Discard {num} card".format({"num": amountOfCardsToDiscard})

func receiveSelection(cards: Array[CardData]):
	selectedCards = cards
	cardSelectionDone.emit()

func mergeEffectSepecific(newEffect: GameEffect):
	assert(discardFrom == newEffect.discardFrom)
	if amountOfCardsToDiscard == -1 or newEffect.amountOfCardsToDiscard == -1:
		print('already discarding all no merging needed')
		return
	else:
		amountOfCardsToDiscard += newEffect.amountOfCardsToDiscard
