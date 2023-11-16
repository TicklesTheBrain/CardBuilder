extends Resource
class_name CardData

@export var cardTitle: String
@export var value: CardParam
@export var type: String
@export var cost: CardParam
@export var stats: StatData

@export var onPlayEffects: Array[PlayEffect] = []
@export var playConditionals: Array[Conditional] = []
@export var onLoseEffects: Array[PlayEffect] = []
@export var onWinEffects: Array[PlayEffect] = []
@export var onBustEffects: Array[PlayEffect] = []
@export var endRoundEffects: Array[PlayEffect] = []
@export var drawEffects: Array[PlayEffect] = []
@export var startMatchEffects: Array[PlayEffect] = []

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

func triggerEffectBucket(bucketToTrigger: Array[PlayEffect]):
	for eff in bucketToTrigger:
		updateContext()
		context.actingCard = self
		await eff.trigger(context)

func triggerEffect(typeToTrigger: PlayEffect.triggerType):
	
	match typeToTrigger:
		PlayEffect.triggerType.PLAY:
			await triggerEffectBucket(onPlayEffects)
		PlayEffect.triggerType.LOSE:
			await triggerEffectBucket(onLoseEffects)
		PlayEffect.triggerType.WIN:
			await triggerEffectBucket(onWinEffects)
		PlayEffect.triggerType.BUST:
			await triggerEffectBucket(onBustEffects)
			await triggerEffectBucket(onLoseEffects)
		PlayEffect.triggerType.END_ROUND:
			await triggerEffectBucket(endRoundEffects)
		PlayEffect.triggerType.DRAW:
			await triggerEffectBucket(drawEffects)
		PlayEffect.triggerType.START_MATCH:
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
