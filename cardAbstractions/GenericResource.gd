extends Node
class_name GenericResource

signal amountChanged(newAmount: int)

@export var resourceName: String
@export var startingValue: int
@export var resetAmount: int
@export var capAtZero: bool

@export var debugLabel: Label
@export var amount: int = startingValue:
	set(value):
		if capAtZero:
			amount = max(value, 0)
		else:
			amount = value
		amountChanged.emit(amount)

func reset():
	amount = resetAmount

func updateLabel(newAmount):
	debugLabel.text = str(newAmount)

func _ready():
	amountChanged.connect(updateLabel)
