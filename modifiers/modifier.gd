extends Resource
class_name Modifier

@export var inEffect: bool = true
@export var staticText: String

var active: bool:
    get:
        if inEffect:
            var deactivators = timingChecks.filter(func(check): return check.type == TimingCheck.CheckType.DEACTIVATOR)
            return not deactivators.any(func(deac): return deac.turnOff == true)
        else:
            var activators = timingChecks.filter(func(check): return check.type == TimingCheck.CheckType.ACTIVATOR)
            if activators.any(func(act): return act.turnOn == true):
                inEffect = true
                return true
            return false

var cleanMeUp: bool:
    get:
        if not inEffect:
            return false
        else:
            if not active:
                return true
            return false    

@export var timingChecks: Array[TimingCheck] = []

func addTC(newTC: TimingCheck):
    timingChecks.append(newTC)

func getText():
    if not staticText:
        return "default text not overriden."
    return staticText
