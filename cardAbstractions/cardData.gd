extends Resource
class_name CardData

@export var cardTitle: String
@export var value: CardParam
@export var type: String
@export var cost: CardParam
@export var stats: StatData

@export var onPlayEffects: Array[PlayEffect] = []

var container: CardContainer 
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

func triggerEffect(typeToTrigger: PlayEffect.triggerType):
	match typeToTrigger:
		PlayEffect.triggerType.PLAY:
			for ef in onPlayEffects:
				updateContext()
				context.actingCard = self
				ef.trigger(context)

func getPlayEffectText() -> String:
	var result = ''
	for effect in onPlayEffects:	
		if result != '':
			result += " "
		result += effect.getText()
	return result


func getOtherText():
	var result = ''
	result += cost.getText() + value.getText() + stats.getText()
	return result




