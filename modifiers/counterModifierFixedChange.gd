extends CounterModifier
class_name CounterModifierFixedChange

@export var shift: int = 1

func calculateSpecific(_container: CardContainer, currValue: int):
    #print('calculate specific called', currValue, shift)
    return currValue + shift