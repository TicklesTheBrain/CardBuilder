extends Node
class_name GenericResource

signal amountChanged(newAmount: int)

@export var resourceName: String
@export var startingValue: int
@export var resetAmount: int

@export var debugLabel: Label
@export var amount: int = startingValue:
	set(value):
		amount = value
		amountChanged.emit(value)

func reset():
	amount = resetAmount

func updateLabel(newAmount):
	debugLabel.text = str(newAmount)

func _ready():
	amountChanged.connect(updateLabel)
