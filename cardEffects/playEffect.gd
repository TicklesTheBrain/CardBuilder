extends Resource
class_name PlayEffect

enum triggerType {NONE, PLAY, DISCARD, END_ROUND, DRAW, START_MATCH, WIN, LOSE, BUST}

@export var effectName: String
@export var staticText: String
@export var conditionals: Array[Conditional]
@export var followUpEffects: Array[PlayEffect] = []
@export var includeFollowUpText: bool = false

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
