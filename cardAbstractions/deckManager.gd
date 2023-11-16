extends CardContainer
class_name DeckManager

@export var debug: bool = true
@export var emptyCardArray: Array[EmptyCardData]

func buildNewEmptyDeck():	
	for empty in emptyCardArray:
		if debug and not empty.debug:
			continue
		for i in range(empty.amount):
			var newCard = CardData.new()
			newCard.value = empty.value.duplicate()
			newCard.type = empty.type
			newCard.cost = empty.cost.duplicate()
			newCard.stats = StatData.new()
			newCard.stats.attack = randi_range(1,2)
			newCard.stats.defence = randi_range(0,1)
			
			newCard.onPlayEffects = [] as Array[CardEffect]
			for pe in empty.onPlayEffects:
				newCard.onPlayEffects.append(pe.duplicate(true))

			newCard.onLoseEffects = [] as Array[CardEffect]
			for pe in empty.onLoseEffects:
				newCard.onLoseEffects.append(pe.duplicate(true))

			newCard.onWinEffects = [] as Array[CardEffect]
			for pe in empty.onWinEffects:
				newCard.onWinEffects.append(pe.duplicate(true))

			newCard.onBustEffects = [] as Array[CardEffect]
			for pe in empty.onBustEffects:
				newCard.onBustEffects.append(pe.duplicate(true))

			newCard.endRoundEffects = [] as Array[CardEffect]
			for pe in empty.endRoundEffects:
				newCard.endRoundEffects.append(pe.duplicate(true))

			newCard.drawEffects = [] as Array[CardEffect]
			for pe in empty.drawEffects:
				newCard.drawEffects.append(pe.duplicate(true))
		
			newCard.startMatchEffects = [] as Array[CardEffect]
			for pe in empty.startMatchEffects:
				newCard.startMatchEffects.append(pe.duplicate(true))

			newCard.playConditionals = [] as Array[Conditional]
			for pc in empty.playConditionals:
				newCard.playConditionals.append(pc.duplicate(true))

			addCard(newCard)



