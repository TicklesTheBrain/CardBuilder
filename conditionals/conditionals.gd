extends Resource
class_name Conditional

@export var staticText: String
@export var containerToCheck: Game.ContainerPurposes

func getText():
    if staticText:
        return staticText
    else:
        return getTextSpecific()

func check(_ctxt: GameStateContext):
    print('default conditional function not overriden')
    return true

func getTextSpecific():
    return "conditional text not overriden"