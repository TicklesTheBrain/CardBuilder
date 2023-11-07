extends Modifier
class_name CounterModifier

@export var type: ContainerCounter.countWhat

func calculate(container: CardContainer, valueToModify: int):
    if not active:
        return valueToModify
    valueToModify = calculateSpecific(container, valueToModify)
    return valueToModify

func calculateSpecific(_container: CardContainer, value: int):
    print("generic Counter modifier calculate not overriden")
    return value