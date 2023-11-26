extends Node2D

@export var typeProperties: Array[CardTypeDisplayProperties]
@export var numberLabel: Label
@export var cornerSymbol: Sprite2D
@export var symbolPositions: Node2D
@export var coloredGroup: CanvasGroup
@export var subviewPort: SubViewport
@export var subCamera: Camera2D
@export var renderSprite: Sprite2D
@export var background: Sprite2D

@export var testType: CardType.Types
@export var testNumber: int

func _ready():
	setup(testType, testNumber)
	await RenderingServer.frame_post_draw
	# RenderingServer.force_draw()
	#renderSprite.texture = ImageTexture.create_from_image(subviewPort.get_texture().get_image())

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

func getCardImage(type: CardType.Types, number: int, receivingFunction: Callable):
	setup(type, number)
	await RenderingServer.frame_post_draw
	receivingFunction.call(ImageTexture.create_from_image(subviewPort.get_texture().get_image()))



