extends Node2D

@export var typeProperties: Array[CardTypeDisplayProperties]
@export var numberLabel: Label
@export var cornerSymbol: Sprite2D
@export var symbolPositions: Node2D
@export var coloredGroup: CanvasGroup
@export var subviewPort: SubViewport
@export var renderSprite: Sprite2D

@export var testType: CardType.Types
@export var testNumber: int

func _ready():
	setup(testType, testNumber)
	await RenderingServer.frame_post_draw
	var image = subviewPort.get_texture().get_image()
	renderSprite.texture = ImageTexture.create_from_image(image)

func setup(type: CardType.Types, number: int):
	assert(number >= 0 and number <= 11)
	numberLabel.text = str(number)
	var symbolProperties = typeProperties.filter(func(p): return p.cardType == type)[0]
	coloredGroup.modulate = symbolProperties.typeColor
	cornerSymbol.texture = symbolProperties.cardSymbolSprite
	var positionGroup = symbolPositions.find_child(str(number))

	for i in range(number):
		var newSprite = Sprite2D.new()
		newSprite.texture = symbolProperties.cardSymbolSprite
		newSprite.position = positionGroup.get_children()[i].position
		coloredGroup.add_child(newSprite)

