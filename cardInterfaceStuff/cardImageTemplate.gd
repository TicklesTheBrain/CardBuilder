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
@export var maxColumnItems: int = 10
@export var typeProperties: Array[CardTypeDisplayProperties]
@export var cardEffectSymbolReference: Array[EffectDisplayProperties]
@export var playConditionSymbol: Texture2D
@export var defaultSymbol: Texture2D

var columnNodes = []

func symbolArrayReduce(acc, source):
	var a = []
	a.append_array(acc)
	a.append_array(source.symbols)
	return a

func setup(cardData: CardData):
	
	if cardData.playConditionals.size() > 0:
		columnNodes.push_back(addSymbol(playConditionSymbol))

	addSymbols(cardData.value.modifiers.reduce(symbolArrayReduce, []), cardEffectSymbolReference)
	addSymbols(cardData.cost.modifiers.reduce(symbolArrayReduce, []), cardEffectSymbolReference)
	addSymbols(cardData.attack.modifiers.reduce(symbolArrayReduce, []), cardEffectSymbolReference)
	addSymbols(cardData.defence.modifiers.reduce(symbolArrayReduce, []), cardEffectSymbolReference)
	addSymbols(cardData.startMatchEffects.reduce(symbolArrayReduce, []), cardEffectSymbolReference, "S:")
	addSymbols(cardData.drawEffects.reduce(symbolArrayReduce, []), cardEffectSymbolReference, "D:")
	addSymbols(cardData.onPlayEffects.reduce(symbolArrayReduce, []), cardEffectSymbolReference, "P:")
	addSymbols(cardData.onWinEffects.reduce(symbolArrayReduce, []), cardEffectSymbolReference, "W:")
	addSymbols(cardData.onLoseEffects.reduce(symbolArrayReduce, []), cardEffectSymbolReference, "L:")
	addSymbols(cardData.onBustEffects.reduce(symbolArrayReduce, []), cardEffectSymbolReference, "B:")
	addSymbols(cardData.endRoundEffects.reduce(symbolArrayReduce, []), cardEffectSymbolReference, "E:")

	if columnNodes.size() > maxColumnItems:
		for node in columnNodes:
			node.visible = false
		addLetter('S')
		addLetter('O')
		addLetter(" ")
		addLetter("M")
		addLetter("A")
		addLetter("N")
		addLetter("Y")
	
	if cardData.cardName == "null":
		CardNamingLord.askToNameCard(cardData)

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
	
func addSymbols(identifierArray, identifierReference: Array[EffectDisplayProperties], precedingLetter = null):
	var letterAdded = false
	for id in identifierArray:
		var symbolTexture = defaultSymbol
		var matching = identifierReference.filter(func(p): return p.cardEffectSymbolFlag == id)
		if matching.size() > 0:
			symbolTexture = matching[0].texture
		if not letterAdded and precedingLetter != null:
			columnNodes.push_back(addLetter(precedingLetter))
			letterAdded = true
		columnNodes.push_back(addSymbol(symbolTexture))
		

func addSymbol(texture: Texture2D):

	var newSymbol = infoColumnSymbol.duplicate()
	newSymbol.texture = texture
	infoSymbolsColumn.add_child(newSymbol)
	newSymbol.visible = true
	return newSymbol

func addLetter(letterToAdd: String):
	var newLetter = infoColumnLetter.duplicate()
	newLetter.text = letterToAdd
	infoSymbolsColumn.add_child(newLetter)
	newLetter.visible = true
	return newLetter

