extends CanvasLayer
class_name ItemPocketDisplay

@export var animation: AnimationPlayer
@export var positionController: ItemDisplayController
@export var backGroundPanel: NinePatchRect
@export var infoLabel: Label
@export var pocketContainer: ItemContainer

signal pocketOpened()
signal cardPocketClosed()

func adjustPanel():
	var shapeCenter = positionController.relevantShape.position
	var shapeSize = positionController.relevantShape.shape.size
	var topLeftCorner = shapeCenter - shapeSize/2

	backGroundPanel.position = topLeftCorner
	backGroundPanel.size = shapeSize

func setupPositionController(container: CardContainer):
	positionController.setupNewLogicalContainer(container)

func setupText(text: String):
	infoLabel.text = text

func showPocket():
	animation.play("show")
	await animation.animation_finished
	pocketOpened.emit()

func hidePocket():
	animation.play("hide")
	await animation.animation_finished
	cardPocketClosed.emit()
	queue_free()
