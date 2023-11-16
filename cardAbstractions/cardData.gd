extends Resource
class_name CardData

@export var cardTitle: String
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
	return value.getValue(context, self)

func getCost():
	updateContext()
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
