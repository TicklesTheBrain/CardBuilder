extends SubViewport
class_name CardImageTemplate

@export var numberLabel: Label
@export var cornerSymbol: Sprite2D
@export var symbolPositions: Node2D
@export var typeProperties: Array[CardTypeDisplayProperties]
@export var coloredGroup: CanvasGroup
@export var doublingMana: SelfDoublingSprite
@export var doublingShield: SelfDoublingSprite
@export var doublingSword: SelfDoublingSprite
@export var cardFace: TextureRect
@export var cardEffectSymbolReference: Array[CardInfoDisplayProperties]
@export var conditionalSymbolReference: Array[CardInfoDisplayProperties]
@export var modifierSymbolReference: Array[CardInfoDisplayProperties]

func setup(cardData: CardData):
	#assert(number >= 0 and number <= 11)
	var value = cardData.value.getBaseValue()
	numberLabel.text = str(value)
	var symbolProperties = typeProperties.filter(func(p): return p.cardType == cardData.type.type)[0]
	coloredGroup.modulate = symbolProperties.typeColor
	cornerSymbol.texture = symbolProperties.cardSymbolSprite
	var positionGroup = symbolPositions.find_child(str(value))

	if value > 0 and value < 11:
		cardFace.visible = false
		for i in range(value):
			var newSprite = Sprite2D.new()
			newSprite.texture = symbolProperties.cardSymbolSprite
			newSprite.position = positionGroup.get_children()[i].position
			coloredGroup.add_child(newSprite)
	

	var cost = cardData.cost.getBaseValue()
	if cost == 0:
		doublingMana.visible = false
	elif cost > 1:
		for i in range(cost-1):
			doublingMana = doublingMana.doubleWithOffset()

	var attack = cardData.attack.getBaseValue()
	if attack == 0:
		doublingSword.visible = false
	elif attack > 1:
		for i in range(attack-1):
			doublingSword = doublingSword.doubleWithOffset()

	var defence = cardData.defence.getBaseValue()
	if defence == 0:
		doublingShield.visible = false
	elif defence > 1:
		for i in range(defence-1):
			doublingShield = doublingShield.doubleWithOffset()




