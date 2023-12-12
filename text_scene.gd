extends Node2D
class_name TextScene

@export var labelProto: Label
@export var choiceLabelProto: ChoiceTextOption
@export var okButton: Button
@export var labelAppearTime: float
@export var labelRootContainer: Container

var myStep: StepText
var stringLabels: Array[Label] = []
var showButton = false

signal complete()


func setup(step: StepText):

	myStep = step

	for i in range(step.listOfStrings.size()):
		var string = step.listOfStrings[i]
		var newLabel

		if step.checkIsOption(i):
			newLabel = choiceLabelProto.duplicate()
			choiceLabelProto.get_parent().add_child(newLabel)
		else:
			newLabel = labelProto.duplicate()
			labelProto.get_parent().add_child(newLabel)

		newLabel.visible = true
		newLabel.self_modulate = Color.TRANSPARENT
		newLabel.text = string
		stringLabels.push_back(newLabel)
	
	showButton = step.buttonWait
	okButton.visible = false

	Events.textChoiceClicked.connect(processTextOptionClicked)
	labelProto.queue_free()
	choiceLabelProto.queue_free()

func showText():
	for label in stringLabels:
		var tween = get_tree().create_tween()
		tween.tween_property(label, "self_modulate", Color.WHITE, labelAppearTime)
		await tween.finished
	
	if showButton:
		okButton.visible = true
	elif not myStep.isOption.any(func(c): return c):
		announceComplete()

func announceComplete():
	complete.emit()

func processTextOptionClicked(label: Label):
	var optionNumber = labelRootContainer.get_children().find(label)
	Events.nextStep.emit(myStep.getOutcome(optionNumber))
	announceComplete()