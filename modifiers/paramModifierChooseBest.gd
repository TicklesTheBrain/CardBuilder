extends ParamModifier
class_name ChooseBest

@export var fixedOptions: Array[int]
@export var optionRangeStart: int
@export var optionRangeEnd: int
@export var nonStatic: bool = true

#TODO: we need to display base value here on card displays?
#TODO: need to work out the interaction with highest_lowest played
#TODO: work out which modifiers/effects/conditionals cannot go in the same bucket

var options:
	get:
		if fixedOptions:
			return fixedOptions
		else:
			return range(optionRangeStart, optionRangeEnd+1)

func getText():
	var text = ""
	if fixedOptions:
		text = "Value can be any of these: {array}".format({"array": fixedOptions})
	else:
		text = "Value is anything between {no1} and {no2}".format({"no1": optionRangeStart, "no2": optionRangeEnd})
	return text

func calculateSpecific(ctxt: GameStateContext, _currValue: int, card: CardData):

	#ESTABLISH SOME BASE VARIABLES
	var playArea = ctxt.player.playArea
	var bustValue = ctxt.player.bustValue.amount
	var allCards = playArea.getAll()
	var staticCards = allCards.filter(func(c): return not c.value.checkIsNonStatic())
	var totalStaticValue = staticCards.reduce(func(acc, c): return acc+c.getValue(), 0)
	var nonStaticCards = allCards.filter(func(c): return c.value.checkIsNonStatic())
	var targetValueForNonStatic = bustValue - totalStaticValue

	#Might have a case where the card is not in play yet and wants a value
	if not nonStaticCards.has(card):
		nonStaticCards.append(card)
   
   #Might have a case where we're already busted whatever the case, we then choose the smallest value
	if totalStaticValue >= bustValue:
		return options.min()
	
	var smallestNonStaticSum = nonStaticCards.map(func(c): return c.value.getNonStaticOptions().min()).reduce(func(acc, n): return acc+n,0)
	if targetValueForNonStatic <= smallestNonStaticSum:
		return options.min()

	#Setup for getting all the permutations	
	var allPerms = []
	var numberOfPermutations = nonStaticCards.map(func(c): return c.value.getNonStaticOptions().size()).reduce(func(acc, n): return acc*n,1)
	var permutationCounters = []

	for nsCard in nonStaticCards:
		var newCounter = {}
		newCounter['card'] = nsCard
		newCounter['options'] = nsCard.value.getNonStaticOptions()
		newCounter['length'] = newCounter['options'].size()
		newCounter['counter'] = 0
		permutationCounters.append(newCounter)

	#Calculate all permuations
	for i in range(numberOfPermutations):
		var newPerm = {}
		newPerm['chosen'] = []
		for nsCardCounter in permutationCounters:
			newPerm['chosen'].append({"card": nsCardCounter.card, "option": nsCardCounter.options[nsCardCounter.counter]})
		newPerm['sum'] = newPerm.chosen.reduce(func(acc,c): return acc+c.option, 0)
		newPerm['difference'] = targetValueForNonStatic - newPerm.sum
		allPerms.append(newPerm)
		if newPerm.difference == 0:
			break #We already found the perfect permutation, we can exit early
		for nsCardCounter in permutationCounters:
			if nsCardCounter.counter < nsCardCounter.length - 1:
				nsCardCounter.counter += 1
				break
			else:
				nsCardCounter.counter = 0		

	#Filter out busting ones and choose closest to target from the rest
	var nonBustingPermutations = allPerms.filter(func(p): return p.difference >= 0)
	nonBustingPermutations.sort_custom(func(a,b): return a.difference < b.difference)
	var chosenPermutation = nonBustingPermutations[0]
	return chosenPermutation.chosen.filter(func(p): return p.card == card)[0].option

func mergeModifierSpecific(newModifier: Modifier):
	assert(type == newModifier.type)
	if not fixedOptions and not newModifier.fixedOptions:
		optionRangeStart = min(optionRangeStart, newModifier.optionRangeStart)
		optionRangeEnd = max(optionRangeEnd, newModifier.optionRangeEnd)
	else:
		var newOptions = options.append_array(newModifier.options)		
		var seenValues = {}
		for op in newOptions:
			seenValues[op] = ""
		fixedOptions = seenValues.keys()
