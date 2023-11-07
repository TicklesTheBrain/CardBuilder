extends Node

signal requestContext(requestingObject)
signal cardAdded(to: CardContainer, card: CardData)
signal playerTurnStart()
signal playerTurnEnd(playerValue: int, buster: bool)
signal newCardDisplayRequested(card: CardData)
signal updateAllDisplays()
signal requestShowPocket(pocketText: String)
signal requestHidePocket()
signal orphanedCardDisplay(cd: CardDisplay)



func _ready():
	cardAdded.connect(displayUpdateWrapper)
	playerTurnStart.connect(displayUpdateWrapper)
	playerTurnEnd.connect(displayUpdateWrapper)

func displayUpdate():
	updateAllDisplays.emit()

func displayUpdateWrapper(_discardedVar1 = null, _discardedVar2 = null):
	call_deferred("displayUpdate")
