extends Node2D
class_name TextScene

@export var labelProto: Label
@export var okButton: Button
@export var labelAppearTime: float

var stringLabels: Array[Label] = []
var showButton = false
signal complete()

func setup(step: StepText):
	for string in step.listOfStrings:
		var newLabel = labelProto.duplicate()
		labelProto.get_parent().add_child(newLabel)
		newLabel.visible = true
		newLabel.self_modulate = Color.TRANSPARENT
		newLabel.text = string
		stringLabels.push_back(newLabel)
	
	showButton = step.buttonWait
	okButton.visible = false

func showText():
	for label in stringLabels:
		var tween = get_tree().create_tween()
		tween.tween_property(label, "self_modulate", Color.WHITE, labelAppearTime)
		await tween.finished
	
	if showButton:
		okButton.visible = true
	else:
		announceComplete()

func announceComplete():
	complete.emit()
