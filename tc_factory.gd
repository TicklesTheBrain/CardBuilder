extends Node

enum EventType {TURN_START, TURN_END, CARD_ADD}

func createTC(type: TimingCheck.CheckType, counter: int, event: EventType, card: CardData = null , container: CardContainer = null):
	var newTC = TimingCheck.new()
	newTC.type = type
	newTC.counter = counter
	match event:
		EventType.TURN_START:
			newTC.connectTurnStart()
		EventType.TURN_END:
			newTC.connectTurnEnd()
		EventType.CARD_ADD:
			newTC.connectCardPlayed()
			newTC.excludeCard = card
			newTC.containerSubject = container

	return newTC
		