extends Resource
class_name TC_Rule

@export var event: TcFactory.EventType
@export var actOrDeact: TimingCheck.CheckType
@export var counter: int = -1

func createNewTC(ctxt: GameStateContext):
    return TcFactory.createTC(actOrDeact, counter, event,ctxt)