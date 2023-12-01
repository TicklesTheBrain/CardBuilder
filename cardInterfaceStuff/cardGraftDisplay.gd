extends CardDisplay
class_name CardGraftDisplay

@export var increaseColor: Color
@export var decreaseColor: Color

func updateCardDetails(dataToShow: CardData = cardData):

	updateParamField(valueLabel, dataToShow.value.getBaseValue(), "Value: ")
	updateParamField(costLabel, dataToShow.cost.getBaseValue(), "Cost: ")
	updateParamField(attackLabel, dataToShow.attack.getBaseValue(), "Attack: ")
	updateParamField(defenceLabel, dataToShow.defence.getBaseValue(), "Defence: ")	
	
	updateAllTextFields(dataToShow)	

func updateCardImage(_data: CardData = cardData):
	pass #JUST DO NOTHING HERE

func _ready():
	super()
	selectionNode = detailedInfoRoot

func updateParamField(label: Label, value: int, stringPrefix: String):
	if value != 0:
		label.visible = true
		var increase = value > 0
		label.text = "{prefix}{symbol}{amount}".format({"symbol": "+" if increase else "", "amount": value, "prefix": stringPrefix})
		if increase:
			label.set("theme_override_colors/font_color", increaseColor)
		else:
			label.set("theme_override_colors/font_color", decreaseColor)
	else:
		label.text = ""
		label.visible = false

