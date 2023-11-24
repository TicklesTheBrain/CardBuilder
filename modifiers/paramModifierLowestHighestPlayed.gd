extends ParamModifier
class_name ModifierHighestLowestPlayed

enum setToType {HIGHEST, LOWEST}
@export var setTo: setToType

func calculateSpecific(ctxt: GameStateContext, _currValue: int, _card: CardData):
	var playedCards = ctxt.player.playArea.getAll() #TODO: This breaks on application to enemy
	if playedCards.size() == 0:
		return 0
	var allBaseValues = []
	if type == CardParam.ParamType.COST:
		allBaseValues = playedCards.map(func(c: CardData): return c.cost.getBaseValue())
	elif type == CardParam.ParamType.VALUE:
		allBaseValues = playedCards.map(func(c: CardData): return c.value.getBaseValue())
   
	#print('all base values', allBaseValues)
	if setTo == setToType.HIGHEST:
		return allBaseValues.max()
	elif setTo == setToType.LOWEST:
		return allBaseValues.min()

	

   
