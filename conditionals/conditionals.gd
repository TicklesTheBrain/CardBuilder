extends Resource
class_name Conditional

@export var staticText: String
@export var containerToCheck: Actor.ContainerPurposes
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

func mergeConditional(newConditional: Conditional):
    assert(containerToCheck == newConditional.containerToCheck)
    mergeConditionalSpecific(newConditional)

func mergeConditionalSpecific(_newConditiona: Conditional):
    print ("if this is not overriden, conditional merge has no effect", conditionalName)
