extends Resource
class_name Item

@export var useEffects: Array[GameEffect] = []
@export var value: int
@export var itemName: String
@export var itemTexture: Texture2D

var container: ItemContainer
var context: GameStateContext

func use():
    for eff in useEffects:
        updateContext()
        await eff.trigger(context)

    if container != null:
        container.removeItem(self)

func receiveContext(ctxt: GameStateContext):
    context = ctxt

func updateContext():
    Events.requestContext.emit(receiveContext)