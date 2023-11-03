extends Node

signal requestContext(requestingObject)
signal cardAdded(to: CardContainer, card: CardData)
signal playerTurnStart()
signal playerTurnEnd()
signal newCardDisplayRequested(card: CardData)
