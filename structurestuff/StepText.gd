extends StructureStep
class_name StepText

@export var listOfStrings: Array[String] = []
@export var buttonWait: bool = true
@export var isOption: Array[bool] = []
@export var optionOutcomes: Array[StructureStep] = []

func checkIsOption(idx: int):
    if isOption.size()-1 >= idx:
        return false
    else:
        return isOption[idx]

func getOutcome(optionChosen: int) -> StructureStep:
    var outcomeNo = isOption.slice(0, optionChosen+1).count(true)
    return optionOutcomes[outcomeNo-1]

