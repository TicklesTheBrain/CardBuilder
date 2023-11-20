extends Resource
class_name CardData

@export var cardTitle: String
@export var graft: bool
@export var value: CardParam
@export var type: String
@export var cost: CardParam
@export var stats: StatData

@export var onPlayEffects: Array[CardEffect] = []
@export var playConditionals: Array[Conditional] = []
@export var onLoseEffects: Array[CardEffect] = []
@export var onWinEffects: Array[CardEffect] = []
@export var onBustEffects: Array[CardEffect] = []
@export var endRoundEffects: Array[CardEffect] = []
@export var drawEffects: Array[CardEffect] = []
@export var startMatchEffects: Array[CardEffect] = []

var container: CardContainer:
	set (new):
		if container:
			prevContainer = container
		container = new
var prevContainer: CardContainer 
var context: GameStateContext

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

func receiveContext(ctxt: GameStateContext):
	context = ctxt

func updateContext():
	Events.requestContext.emit(self)

func triggerEffectBucket(bucketToTrigger: Array[CardEffect]):
	for eff in bucketToTrigger:
		updateContext()
		context.actingCard = self
		await eff.trigger(context)

func triggerEffect(typeToTrigger: CardEffect.triggerType):
	
	match typeToTrigger:
		CardEffect.triggerType.PLAY:
			await triggerEffectBucket(onPlayEffects)
		CardEffect.triggerType.LOSE:
			await triggerEffectBucket(onLoseEffects)
		CardEffect.triggerType.WIN:
			await triggerEffectBucket(onWinEffects)
		CardEffect.triggerType.BUST:
			await triggerEffectBucket(onBustEffects)
			await triggerEffectBucket(onLoseEffects)
		CardEffect.triggerType.END_ROUND:
			await triggerEffectBucket(endRoundEffects)
		CardEffect.triggerType.DRAW:
			await triggerEffectBucket(drawEffects)
		CardEffect.triggerType.START_MATCH:
			await triggerEffectBucket(startMatchEffects)
		
func getPlayEffectText() -> String:
	var result = ''
	for effect in onPlayEffects:	
		if result != '':
			result += " "
		result += effect.getText()
	return result

func getOtherText():
	var result = ''
	result += cost.getText() + value.getText() + stats.getText() + getPlayConditionalText()
	return result

func checkPlayConditionals() -> bool:
	updateContext()
	context.actingCard = self
	for con in playConditionals:
		if not con.check(context):
			return false
	return true

func getPlayConditionalText():
	var result = ''
	for con in playConditionals:
		result += con.getText()
	return result

func applyCardGraft():
	pass

func duplicateSelf() -> CardData:
	var newCard = CardData.new()
	newCard.value = value.duplicate()
	newCard.type = type
	newCard.graft = graft
	newCard.cost = cost.duplicate()
	newCard.stats = stats.duplicate()

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
	value.baseValue += newGraft.value.baseValue
	type = newGraft.type
	cost.baseValue += newGraft.cost.baseValue
	stats.attack += newGraft.stats.attack
	stats.defence += newGraft.stats.defence

	CardData.mergeEffectsBuckets(onPlayEffects, newGraft.onPlayEffects)
	CardData.mergeEffectsBuckets(onLoseEffects, newGraft.onLoseEffects)
	CardData.mergeEffectsBuckets(onWinEffects, newGraft.onWinEffects)
	CardData.mergeEffectsBuckets(onBustEffects, newGraft.onBustEffects)
	CardData.mergeEffectsBuckets(endRoundEffects, newGraft.endRoundEffects)
	CardData.mergeEffectsBuckets(drawEffects, newGraft.drawEffects)
	CardData.mergeEffectsBuckets(startMatchEffects, newGraft.startMatchEffects)

	CardData.mergeConditionalsBuckets(playConditionals, newGraft.playConditionals)

	return self

static func mergeEffectsBuckets(ownBucket: Array[CardEffect], graftBucket: Array[CardEffect]):
	var effectsToAppend = []
	for ef in graftBucket:
		var sameNameEffects = ownBucket.filter(func(e): return ef.effectName and ef.effectName == e.effectName)
		if sameNameEffects.size() > 0:
			for sne in sameNameEffects:
				sne.mergeEffect(ef)
		else:
			effectsToAppend.push_back(ef)
	effectsToAppend = effectsToAppend.map(func(e): return e.duplicate(true)) as Array[CardEffect]
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
	conditionalsToAppend = conditionalsToAppend.map(func(c): return c.duplicate(true) as Array[Conditional])
	bucketToGraft.append_array(conditionalsToAppend)


