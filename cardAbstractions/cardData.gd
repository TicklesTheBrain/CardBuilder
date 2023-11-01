extends Resource
class_name CardData

@export var cardTitle: String
@export var value: int
@export var type: String
@export var cost: int
@export var cardText: String
@export var stats: StatData

@export var onPlayEffects: Array[PlayEffect] = []
@export var modifiers: Array[CardModifier] = []
 
var context: GameStateContext

func getValue():
    return value

func getCost():
    var returnCost = cost
    updateContext()
    for modifier in modifiers:
        if is_instance_of(modifier, CostModifier):
            context.modifiableValue = returnCost
            returnCost = modifier.calculateCost(context) 

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


