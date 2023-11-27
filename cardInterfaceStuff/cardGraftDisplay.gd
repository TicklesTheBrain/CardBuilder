extends CardDisplay
class_name CardGraftDisplay

@export var increaseColor: Color
@export var decreaseColor: Color

func updateCardDisplay(_dataToShow: CardData = cardData):

	var baseValue = cardData.value.getBaseValue()
	if baseValue != 0:
		valueLabel.text = "{symbol}{amount}".format({"symbol": "+" if baseValue > 0 else "-", "amount": baseValue})

	var baseCost = cardData.cost.getBaseValue()
	if baseCost != 0:
		var increaseCost = baseCost > 0
		costLabel.text = "{symbol}{amount}".format({"symbol": "+" if increaseCost else "-", "amount": baseCost})
		if increaseCost:
			costLabel.set("theme_override_colors/font_color", increaseColor)
		else:
			costLabel.set("theme_override_colors/font_color", decreaseColor)
	
	updateAllTextFields(_dataToShow)
	
	var attackValue = cardData.attack.getBaseValue()
	if attackValue != 0:
		var increaseAttack = attackValue > 0
		attackLabel.text = "{symbol}{amount}".format({"symbol": "+" if increaseAttack else "-", "amount": attackValue})
		if increaseAttack:
			attackLabel.set("theme_override_colors/font_color", increaseColor)
		else:
			attackLabel.set("theme_override_colors/font_color", decreaseColor)
	else:
		attackLabel.text = ""

	var defenceValue = cardData.defence.getBaseValue()
	if defenceValue != 0:
		var increaseDefence = defenceValue > 0
		defenceLabel.text = "{symbol}{amount}".format({"symbol": "+" if increaseDefence else "-", "amount": defenceValue})
		if increaseDefence:
			defenceLabel.set("theme_override_colors/font_color", increaseColor)
		else:
			defenceLabel.set("theme_override_colors/font_color", decreaseColor)
	else:
		defenceLabel.text = ""
