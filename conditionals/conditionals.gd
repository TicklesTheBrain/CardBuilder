extends Resource
class_name Conditional

@export var staticText: String
@export var containerToCheck: Game.ContainerPurposes
@export var conditionalName: String

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

func mergeConditional(_newCondiitional: Conditional):
    print ("if this is not overriden, conditional merge has no effect")