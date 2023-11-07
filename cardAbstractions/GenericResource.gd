extends Node
class_name GenericResource

signal amountChanged(newAmount: int)

@export var resourceName: String
@export var baseline: int
@export var resetAdjust: int = 0
@export var capAtZero: bool

@export var debugLabel: Label
@export var amount: int = baseline:
	set(value):
		if capAtZero:
			amount = max(value, 0)
		else:
			amount = value
		amountChanged.emit(amount)

func reset():
	amount = baseline + resetAdjust

func updateLabel(newAmount):
	debugLabel.text = str(newAmount)

func _ready():
	if debugLabel:
		amountChanged.connect(updateLabel)


