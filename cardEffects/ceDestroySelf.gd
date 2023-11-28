extends CardEffect
class_name DestroySelf

@export var destroyPermanent: bool = false

func triggerSpecific(ctxt: GameStateContext):
	var card = ctxt.actingCard
	if destroyPermanent and card.templateCard != null:
		card.templateCard.amount = max(card.templateCard.amount-1,0)
		print('permanent destroy triggered, new template amount ', card.templateCard.amount)
	if card.container != null:
		card.container.removeCard(card)
	card.announceDestroy.emit()
