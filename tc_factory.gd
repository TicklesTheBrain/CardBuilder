extends Node

enum EventType {TURN_START, TURN_END, CARD_PLAYED}

func createTC(type: TimingCheck.CheckType, counter: int, event: EventType, ctxt: GameStateContext):
	var newTC = TimingCheck.new()
	newTC.type = type
	newTC.counter = counter
	match event:
		EventType.TURN_START:
			newTC.connectTurnStart()
		EventType.TURN_END:
			newTC.connectTurnEnd()
		EventType.CARD_PLAYED:
			newTC.connectCardPlayed()
			newTC.excludeCard = ctxt.actingCard
			newTC.containerSubject = ctxt.playArea

	return newTC
		