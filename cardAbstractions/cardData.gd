extends Resource
class_name CardData

@export var cardName: String
@export var revealed: bool = false:
	set(new):
		if revealed != new:
			revealChange.emit()
		revealed = new
@export var cardBack: CardDisplay.BackTypes
@export var graft: bool
@export var value: CardParam
@export var type: CardType
@export var cost: CardParam
@export var attack: CardParam
@export var defence: CardParam

@export var onPlayEffects: Array[GameEffect] = []
@export var playConditionals: Array[Conditional] = []
@export var onLoseEffects: Array[GameEffect] = []
@export var onWinEffects: Array[GameEffect] = []
@export var onBustEffects: Array[GameEffect] = []
@export var endRoundEffects: Array[GameEffect] = []
@export var drawEffects: Array[GameEffect] = []
@export var startMatchEffects: Array[GameEffect] = []
@export var templateCard: EmptyCardData

signal announceDestroy()
signal revealChange()

#TODO: Add exclusion flags for merging
#TODO: Add additional name get identifiers, when merging is possible, but should produce a different symbol

var container: CardContainer:
	set (new):
		if container:
			prevContainer = container
		container = new
var prevContainer: CardContainer 
var context: GameStateContext

func getOwner() -> Actor:
	if not container:
		return null
	return container.ownerActor

func getValue():
	updateContext()
	if not context:
		return value.getBaseValue()
	return value.getValue(context, self)

func getCost():
	updateContext()
	if not context:
		return cost.getBaseValue()
	return cost.getValue(context, self)

func getAttack():
	updateContext()
	if not context:
		return attack.getBaseValue()
	return attack.getValue(context, self)

func getDefence():
	updateContext()
	if not context:
		return defence.getBaseValue()
	return defence.getValue(context, self)

func receiveContext(ctxt: GameStateContext):
	context = ctxt

func updateContext():
	Events.requestContext.emit(receiveContext)

func triggerEffectBucket(bucketToTrigger: Array[GameEffect]):
	for eff in bucketToTrigger:
		updateContext()
		context.actingCard = self
		await eff.trigger(context)

func triggerEffect(typeToTrigger: GameEffect.triggerType):
	
	match typeToTrigger:
		GameEffect.triggerType.PLAY:
			await triggerEffectBucket(onPlayEffects)
		GameEffect.triggerType.LOSE:
			await triggerEffectBucket(onLoseEffects)
		GameEffect.triggerType.WIN:
			await triggerEffectBucket(onWinEffects)
		GameEffect.triggerType.BUST:
			await triggerEffectBucket(onBustEffects)
		GameEffect.triggerType.END_ROUND:
			await triggerEffectBucket(endRoundEffects)
		GameEffect.triggerType.DRAW:
			await triggerEffectBucket(drawEffects)
		GameEffect.triggerType.START_MATCH:
			await triggerEffectBucket(startMatchEffects)

func getEffectTextDictionary():
	return {
		"onPlay" = CardData.getEffectTextFromBucket(onPlayEffects),
		"onLose" = CardData.getEffectTextFromBucket(onLoseEffects),
		"onWin" = CardData.getEffectTextFromBucket(onWinEffects),
		"onBust" = CardData.getEffectTextFromBucket(onBustEffects),
		"endRound" = CardData.getEffectTextFromBucket(endRoundEffects),
		"onDraw" = CardData.getEffectTextFromBucket(drawEffects),
		"startMatch" = CardData.getEffectTextFromBucket(startMatchEffects)
	}

func getPlayConditionalText():
	var result = ''
	for con in playConditionals:
		result += con.getText()
	return result

static func getEffectTextFromBucket(bucketToQuery: Array[GameEffect]):
	var result = ''
	for effect in bucketToQuery:	
		if result != '':
			result += " "
		result += effect.getText()
	return result

func getParamTextDictionary():
	return {
		"attack" = attack.getText(),
		"defence" = defence.getText(),
		"cost" = cost.getText(),
		"value" = value.getText()
	}

func checkPlayConditionals() -> bool:
	updateContext()
	context.actingCard = self
	for con in playConditionals:
		if not con.check(context):
			return false
	return true


func applyCardGraft():
	pass

func duplicateSelf() -> CardData:
	var newCard = CardData.new()
	newCard.cardName = cardName
	newCard.value = value.duplicate(true)
	newCard.type = type.duplicate(true)
	newCard.graft = graft
	newCard.revealed = revealed
	newCard.cardBack = cardBack
	newCard.cost = cost.duplicate(true)
	newCard.attack = attack.duplicate(true)
	newCard.defence = defence.duplicate(true)

	#TODO: Is this correct? Do we always want to pass on this info to the duplicate?
	newCard.container = container
	newCard.prevContainer = prevContainer

	CardData.mergeEffectsBuckets(newCard.onPlayEffects, onPlayEffects)
	CardData.mergeEffectsBuckets(newCard.onLoseEffects, onLoseEffects)
	CardData.mergeEffectsBuckets(newCard.onWinEffects, onWinEffects)
	CardData.mergeEffectsBuckets(newCard.onBustEffects, onBustEffects)
	CardData.mergeEffectsBuckets(newCard.endRoundEffects, endRoundEffects)
	CardData.mergeEffectsBuckets(newCard.drawEffects, drawEffects)
	CardData.mergeEffectsBuckets(newCard.startMatchEffects, startMatchEffects)

	CardData.mergeConditionalsBuckets(newCard.playConditionals, playConditionals)

	return newCard

func addCardGraft(newGraft: CardData):
	value.mergeCardParam(newGraft.value)
	#type = newGraft.type.duplicate()
	cost.mergeCardParam(newGraft.cost)
	attack.mergeCardParam(newGraft.attack)
	defence.mergeCardParam(newGraft.defence)

	CardData.mergeEffectsBuckets(onPlayEffects, newGraft.onPlayEffects)
	CardData.mergeEffectsBuckets(onLoseEffects, newGraft.onLoseEffects)
	CardData.mergeEffectsBuckets(onWinEffects, newGraft.onWinEffects)
	CardData.mergeEffectsBuckets(onBustEffects, newGraft.onBustEffects)
	CardData.mergeEffectsBuckets(endRoundEffects, newGraft.endRoundEffects)
	CardData.mergeEffectsBuckets(drawEffects, newGraft.drawEffects)
	CardData.mergeEffectsBuckets(startMatchEffects, newGraft.startMatchEffects)

	CardData.mergeConditionalsBuckets(playConditionals, newGraft.playConditionals)

	return self

static func mergeEffectsBuckets(ownBucket: Array[GameEffect], graftBucket: Array[GameEffect]):
	var effectsToAppend = []
	for ef in graftBucket:
		var sameNameEffects = ownBucket.filter(func(e): return ef.effectName and ef.effectName == e.effectName)
		if sameNameEffects.size() > 0:
			for sne in sameNameEffects:
				sne.mergeEffect(ef)
		else:
			effectsToAppend.push_back(ef)
	effectsToAppend = effectsToAppend.map(func(e): return e.duplicate(true)) as Array[GameEffect]
	ownBucket.append_array(effectsToAppend)

static func mergeConditionalsBuckets(bucketToGraft: Array[Conditional], donorBucket: Array[Conditional]):
	var conditionalsToAppend = []
	for con in donorBucket:
		var sameNameConditionals = bucketToGraft.filter(func(c): return con.conditionalName and c.conditionalName == con.conditionalName)
		if sameNameConditionals.size() > 0:
			for snc in sameNameConditionals:
				snc.mergeConditional(con)
		else:
			conditionalsToAppend.push_back(con)
	conditionalsToAppend = conditionalsToAppend.map(func(c): return c.duplicate(true)) as Array[Conditional]
	bucketToGraft.append_array(conditionalsToAppend)

static func mergeModifiersBuckets(bucketToGraft: Array[Modifier], donorBucket: Array[Modifier]):
	var modifiersToAppend = []
	for mod in donorBucket:
		var sameNameModifiers = bucketToGraft.filter(func(m): return mod.modifierName and m.modifierName == mod.modifierName)
		if sameNameModifiers.size() > 0:
			for snm in sameNameModifiers:
				snm.mergeModifier(mod)
		else:
			modifiersToAppend.push_back(mod)
	modifiersToAppend = modifiersToAppend.map(func(m): return m.duplicate(true)) as Array[Modifier]
	bucketToGraft.append_array(modifiersToAppend)


