extends SubViewport
class_name CardImageTemplate

@export_group("Card Image Component References")
@export var infoSymbolsColumn: VBoxContainer
@export var infoColumnLetter: Label
@export var infoColumnSymbol: TextureRect
@export var numberLabel: Label
@export var cornerSymbol: Sprite2D
@export var symbolPositions: Node2D
@export var coloredGroup: CanvasGroup
@export var doublingMana: SelfDoublingSprite
@export var doublingShield: SelfDoublingSprite
@export var doublingSword: SelfDoublingSprite
@export var cardFace: TextureRect
@export var cardNameLabel: Label

@export_group("Card Display Properties")
@export var typeProperties: Array[CardTypeDisplayProperties]
@export var cardEffectSymbolReference: Array[CardInfoDisplayProperties]
@export var conditionalSymbolReference: Array[CardInfoDisplayProperties]
@export var modifierSymbolReference: Array[CardInfoDisplayProperties]

@export var defaultSymbol: Texture2D

func setup(cardData: CardData):
	
	var value = cardData.getValue()
	numberLabel.text = str(value)
	var symbolProperties = typeProperties.filter(func(p): return p.cardType == cardData.type.type)[0]
	coloredGroup.modulate = symbolProperties.typeColor
	cornerSymbol.texture = symbolProperties.cardSymbolSprite
	if cardData.cardName == "" and (value < 1 or value > 10):
		CardNamingLord.askToNameCard(cardData) #TODO: This should be moved somewhere else

	if cardData.cardName != "":
		cardFace.visible = true
		cardFace.texture = CardNamingLord.getCardFace(cardData.cardName)
		cardNameLabel.visible = true
		cardNameLabel.text = cardData.cardName

	else:
		cardFace.visible = false
		cardNameLabel.visible = false
		var positionGroup = symbolPositions.find_child(str(value))
		for i in range(value):
			var newSprite = Sprite2D.new()
			newSprite.texture = symbolProperties.cardSymbolSprite
			newSprite.position = positionGroup.get_children()[i].position
			coloredGroup.add_child(newSprite)	

	var cost = cardData.getCost()
	if cost == 0:
		doublingMana.visible = false
	elif cost > 1:
		for i in range(cost-1):
			doublingMana = doublingMana.doubleWithOffset()

	var attack = cardData.getAttack()
	if attack == 0:
		doublingSword.visible = false
	elif attack > 1:
		for i in range(attack-1):
			doublingSword = doublingSword.doubleWithOffset()

	var defence = cardData.getDefence()
	if defence == 0:
		doublingShield.visible = false
	elif defence > 1:
		for i in range(defence-1):
			doublingShield = doublingShield.doubleWithOffset()

	addSymbols(cardData.playConditionals.map(func(c): return c.conditionalName), conditionalSymbolReference)
	addSymbols(cardData.value.modifiers.map(func(m): return m.modifierName), modifierSymbolReference)
	addSymbols(cardData.cost.modifiers.map(func(m): return m.modifierName), modifierSymbolReference)
	addSymbols(cardData.attack.modifiers.map(func(m): return m.modifierName), modifierSymbolReference)
	addSymbols(cardData.defence.modifiers.map(func(m): return m.modifierName), modifierSymbolReference)
	addSymbols(cardData.startMatchEffects.map(func(m): return m.effectName), cardEffectSymbolReference, "S:")
	addSymbols(cardData.drawEffects.map(func(m): return m.effectName), cardEffectSymbolReference, "D:")
	addSymbols(cardData.onPlayEffects.map(func(m): return m.effectName), cardEffectSymbolReference, "P:")
	addSymbols(cardData.onWinEffects.map(func(m): return m.effectName), cardEffectSymbolReference, "W:")
	addSymbols(cardData.onLoseEffects.map(func(m): return m.effectName), cardEffectSymbolReference, "L:")
	addSymbols(cardData.onBustEffects.map(func(m): return m.effectName), cardEffectSymbolReference, "B:")
	addSymbols(cardData.endRoundEffects.map(func(m): return m.effectName), cardEffectSymbolReference, "E:")

	
func addSymbols(identifierArray, identifierReference: Array[CardInfoDisplayProperties], precedingLetter = null):
	#TODO: add clauses for too many symbols
	var letterAdded = false
	for id in identifierArray:
		if id == null:
			continue
		var symbolTexture = defaultSymbol
		var matching = identifierReference.filter(func(p): return p.identifier == id)
		if matching.size() > 0:
			symbolTexture = matching[0].texture
		if not letterAdded and precedingLetter != null:
			var newLetter = infoColumnLetter.duplicate()
			newLetter.text = precedingLetter
			infoSymbolsColumn.add_child(newLetter)
			newLetter.visible = true
			letterAdded = true
		addSymbol(symbolTexture)
		

func addSymbol(texture: Texture2D):

	var newSymbol = infoColumnSymbol.duplicate()
	newSymbol.texture = texture
	infoSymbolsColumn.add_child(newSymbol)
	newSymbol.visible = true