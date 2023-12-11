extends Node

enum EventType {TURN_START, TURN_END, CARD_PLAYED, CARD_REMOVED_FROM_HAND, CARD_DESTROYED}

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
			newTC.cardSubject = ctxt.actingCard
			newTC.containerSubject = ctxt.actingCard.getOwner().playArea
		EventType.CARD_REMOVED_FROM_HAND:
			newTC.connectCardRemoved()
			newTC.cardSubject = ctxt.actingCard
			newTC.containerSubject = ctxt.actingCard.getOwner().hand

	return newTC
		
