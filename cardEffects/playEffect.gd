extends Resource
class_name PlayEffect

enum triggerType {NONE, PLAY, DISCARD, END, DRAW}

@export var effectName: String
@export var staticText: String
@export var conditionals: Array[Conditional]

func trigger(ctxt: GameStateContext):
	#print('trigger launched', conditionals)
	for conditional in conditionals:
		#print('conditional', conditional)
		if not conditional.check(ctxt):
			#print("conditional failed")
			return
	await triggerSpecific(ctxt)

func triggerSpecific(_effectContext: GameStateContext):
	print('this was a default play effect trigger function that was not overriden. is this expected?')
	#pass

func getText() -> String:
	if staticText:
		return staticText
	else:
		var result = ''
		for con in conditionals:
			result += con.getText()
		result += getTextSpecific()
		return result

func getTextSpecific() -> String:
	return "this was a not overriden generic getText, something wrong?"