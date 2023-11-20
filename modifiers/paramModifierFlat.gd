extends ParamModifier
class_name ModifierFlathange

@export var flatChange: int = -1
@export var increaseOnMerge: bool = false

func calculateSpecific(_ctxt: GameStateContext, _currValue: int, _card: CardData):
    #print('calculate specific called', currValue, shift)
    return flatChange

func mergeModifierSpecific(newModifier: Modifier):
    assert(type == newModifier.type)

    if flatChange == newModifier.flatChange:
        if increaseOnMerge:
            flatChange += 1
        else:
            flatChange -= 1
    else:
        if increaseOnMerge:
            flatChange = max(flatChange, newModifier.flatChange)
        else:
            flatChange = min(flatChange, newModifier.flatChange)
            #TODO: maybe it would be better without the explicit increase on merge flag? just if grafting smaller, reduce, if grafting larger - increase?

    