extends NinePatchRect

@export var controlToMatch: Control
@export var triggerResizeEmitter: Node

func _ready():
    triggerResizeEmitter.resizeTriggered.connect(matchSize)
    #print('ready called for size matcher', triggerResizeEmitter.resizeTriggered.get_connections())

func matchSize():
    #print('resize called')
    size = controlToMatch.size
