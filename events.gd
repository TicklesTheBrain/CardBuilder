extends Node

signal requestContext(receiveContext: Callable)
signal cardAdded(to: CardContainer, card: CardData)
signal startMatch()
signal playerTurnStart()
signal playerTurnEnd(playerValue: int, buster: bool)
signal gameStateChange()
signal newTopMessageRequested(messageText: String)
signal hideTopMessages()
signal textChoiceClicked(textLabel: Label)
signal nextStep(step: StructureStep)

signal confirmButtonEnable()
signal confirmButtonDisable()
signal confirmButtonPressed