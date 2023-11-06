extends PlayEffect
class_name DrawCards

@export var amountOfCardsToDraw: int = 1

func trigger(ctxt: GameStateContext):
	print('card draw triggered')

	for i in range(amountOfCardsToDraw):
		if ctxt.hand.checkFull():
			return
		var newCard = ctxt.drawDeck.drawCard()
		if newCard:
			ctxt.hand.addCard(newCard)
		else:
			return

func getText() -> String:
	return "Draw {num} card".format({"num": amountOfCardsToDraw})
