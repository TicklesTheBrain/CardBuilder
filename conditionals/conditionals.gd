extends Resource
class_name Conditional

@export var staticText: String
@export var conditionalName: String
@export var subjectActor: GameStateContext.ActorType

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
   
    mergeConditionalSpecific(newConditional)

func mergeConditionalSpecific(_newConditiona: Conditional):
    print ("if this is not overriden, conditional merge has no effect", conditionalName)
