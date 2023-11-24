extends Node
class_name GameResource

enum Properties {BASELINE, RESET_ADJUST, RESET_BASELINE, AMOUNT}

signal amountChanged(newAmount: int)

@export var resourceName: String
@export var baseline: int
@export var resetAdjust: int = 0
@export var resetBaseline: int = 0
@export var capAtZero: bool
@export var debugLabel: Label
@export var amount: int:
	set(value):
		if capAtZero:
			amount = max(value, 0)
		else:
			amount = value
		amountChanged.emit(amount)

func reset():
	amount = baseline + resetAdjust
	resetAdjust = resetBaseline

func updateLabel(newAmount):
	debugLabel.text = str(newAmount)

func _ready():
	if debugLabel:
		amountChanged.connect(updateLabel)
	amount = baseline

func setProperty(property: Properties, newValue: int):
	match property:
		Properties.BASELINE:
			baseline = newValue
		Properties.RESET_ADJUST:
			resetAdjust = newValue
		Properties.RESET_BASELINE:
			resetBaseline = newValue
		Properties.AMOUNT:
			amount = newValue

func shiftProperty(property: Properties, shiftAmount: int):
	match property:
		Properties.BASELINE:
			baseline += shiftAmount
		Properties.RESET_ADJUST:
			resetAdjust += shiftAmount
		Properties.RESET_BASELINE:
			resetBaseline += shiftAmount
		Properties.AMOUNT:
			amount += shiftAmount

