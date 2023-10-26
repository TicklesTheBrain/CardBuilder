extends Node2D

@export var valueTypeLabel: Label
@export var costLabel: Label
@export var cardTextLabel: RichTextLabel
@export var attackLabel: Label
@export var defenceLabel: Label
var cardData: CardData

func setupCardDisplay(data: CardData):
	cardData = data
	valueTypeLabel.text = str(data.value) + data.type
	costLabel.text = str(data.cost) + 'E'
	cardTextLabel.text = data.cardText
	
	if data.stats.attack > 0:
		attackLabel.text = str(data.stats.attack) + 'Att'
	else:
		attackLabel.text = ""
	if data.stats.defence >0:
		defenceLabel.text = str(data.stats.defence) + 'Def'
	else:
		defenceLabel.text = ""
