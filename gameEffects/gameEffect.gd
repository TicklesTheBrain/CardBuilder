extends Resource
class_name GameEffect

#Maybe move this to CardData?
enum triggerType {NONE, PLAY, DISCARD, END_ROUND, DRAW, START_MATCH, WIN, LOSE, BUST}

@export var effectName: String
@export var staticText: String
@export var conditionals: Array[Conditional] = []
@export var followUpEffects: Array[GameEffect] = []
@export var includeFollowUpText: bool = false
@export var subjectActor: GameStateContext.ActorType
@export var symbols: Array[EffectDisplayProperties.SymbolFlags]

func trigger(ctxt: GameStateContext):
	#print('trigger launched', conditionals)
	for conditional in conditionals:
		#print('conditional', conditional)
		if not conditional.check(ctxt):
			#print("conditional failed")
			return
	await triggerSpecific(ctxt)
	for eff in followUpEffects:
		await eff.trigger(ctxt)
	Events.gameStateChange.emit()

func triggerSpecific(_effectContext: GameStateContext):
	print('this was a default play effect trigger function that was not overriden. is this expected?')
	#pass

func getText() -> String:
	var result = ''

	if staticText:
		result += staticText
	else:
		for con in conditionals:
			result += con.getText()
		result += getTextSpecific()
	
	if includeFollowUpText:
		for eff in followUpEffects:
			result += eff.getText()
	
	return result

func getTextSpecific() -> String:
	return "this was a not overriden generic getText, something wrong?"

func mergeEffect(newEffect: GameEffect):
	CardData.mergeConditionalsBuckets(conditionals, newEffect.conditionals)
	mergeEffectSepecific(newEffect)
	CardData.mergeEffectsBuckets(followUpEffects, newEffect.followUpEffects)

func mergeEffectSepecific(_newEffect: GameEffect):
	return "if this is not overriden, the merging will have no effect"
