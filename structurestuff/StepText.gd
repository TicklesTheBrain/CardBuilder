extends StructureStep
class_name StepText

@export var listOfStrings: Array[String] = []
@export var buttonWait: bool = true
@export var isOption: Array[bool] = []
@export var optionOutcomes: Array[StructureStep] = []

func checkIsOption(idx: int):
    #print('check is option')
    if isOption.size() <= idx:
        #print('false one')
        return false
    else:
        #print(isOption[idx])
        return isOption[idx]

func getOutcome(optionChosen: int) -> StructureStep:
    var outcomeNo = isOption.slice(0, optionChosen+1).count(true)
    return optionOutcomes[outcomeNo-1]

