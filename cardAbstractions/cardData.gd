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

	mergeEffectsBuckets(newCard.onPlayEffects, onPlayEffects)
	mergeEffectsBuckets(newCard.onLoseEffects, onLoseEffects)
	mergeEffectsBuckets(newCard.onWinEffects, onWinEffects)
	mergeEffectsBuckets(newCard.onBustEffects, onBustEffects)
	mergeEffectsBuckets(newCard.endRoundEffects, endRoundEffects)
	mergeEffectsBuckets(newCard.drawEffects, drawEffects)
	mergeEffectsBuckets(newCard.startMatchEffects, startMatchEffects)
		
	newCard.playConditionals = [] as Array[Conditional]
	for pc in playConditionals:
		newCard.playConditionals.append(pc.duplicate(true))

	return newCard

func addCardGraft(newGraft: CardData):
	value.baseValue += newGraft.value.baseValue
	type = newGraft.type
	cost.baseValue += newGraft.cost.baseValue
	stats.attack += newGraft.stats.attack
	stats.defence += newGraft.stats.defence

	mergeEffectsBuckets(onPlayEffects, newGraft.onPlayEffects)
	mergeEffectsBuckets(onLoseEffects, newGraft.onLoseEffects)
	mergeEffectsBuckets(onWinEffects, newGraft.onWinEffects)
	mergeEffectsBuckets(onBustEffects, newGraft.onBustEffects)
	mergeEffectsBuckets(endRoundEffects, newGraft.endRoundEffects)
	mergeEffectsBuckets(drawEffects, newGraft.drawEffects)
	mergeEffectsBuckets(startMatchEffects, newGraft.startMatchEffects)

	#TODO: Add support for merged conditionals
	for pc in newGraft.playConditionals:
		playConditionals.append(pc.duplicate(true))

	return self

func mergeEffectsBuckets(ownBucket: Array[CardEffect], graftBucket: Array[CardEffect]):
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


