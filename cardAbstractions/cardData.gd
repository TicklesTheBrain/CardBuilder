extends Resource
class_name CardData

@export var cardTitle: String
@export var value: CardParam
@export var type: String
@export var cost: CardParam
@export var cardText: String
@export var stats: StatData

@export var onPlayEffects: Array[PlayEffect] = []

var container: CardContainer 
var context: GameStateContext

func getValue():
	return value

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


