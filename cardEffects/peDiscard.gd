extends CardEffect
class_name DiscardCards

@export var amountOfCardsToDiscard: int = 1
@export var discardFrom: Game.ContainerPurposes

var selectedCards: Array[CardData] = []
signal cardSelectionDone

func triggerSpecific(ctxt: GameStateContext):

	print('card discard triggered')
	var cont = ctxt.getContainerFromPurpose(discardFrom)

	if amountOfCardsToDiscard == -1:
		cont.disposeAll()
	else:
		InputLord.cardSelectionRequested.emit(ctxt.hand, amountOfCardsToDiscard, receiveSelection)
		await cardSelectionDone
		for card in selectedCards:
			cont.disposeCard(card)

func getTextSpecific() -> String:
	if amountOfCardsToDiscard == -1:
		return "discard all cards."
	else:
		return "Discard {num} card".format({"num": amountOfCardsToDiscard})

func receiveSelection(cards: Array[CardData]):
	selectedCards = cards
	cardSelectionDone.emit()

func mergeEffecSpecific(newEffect: CardEffect):
	assert(discardFrom == newEffect.discardFrom)
	if amountOfCardsToDiscard == -1 or newEffect.amountOfCardsToDiscard == -1:
		print('already discarding all no merging needed')
		return
	else:
		amountOfCardsToDiscard += newEffect.amountOfCardsToDiscard
