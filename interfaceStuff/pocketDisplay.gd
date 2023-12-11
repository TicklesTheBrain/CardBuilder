extends CanvasLayer
class_name PocketDisplay

@export var animation: AnimationPlayer
@export var positionController: CardPositionController
@export var backGroundPanel: NinePatchRect
@export var infoLabel: Label
@export var sizesMinCenterDistance: Array[float] = []
@export var sizesMaxCardGaps: Array[float] = []
@export var sizesMultipleRows: Array[bool] = []
@export var sizesRowGaps: Array[float] = []
@export var pocketContainer: CardContainer
@onready var size: PocketSize:
	set (newSize):
		positionController.minCardCenterDistance = sizesMinCenterDistance[newSize]
		positionController.maxCardGap = sizesMaxCardGaps[newSize]
		positionController.multipleRows = sizesMultipleRows[newSize]
		positionController.rowGap = sizesRowGaps[newSize]
		positionController.cardAreaId = newSize
		adjustPanel()
		size = newSize

enum PocketSize {SMALL, MEDIUM, BIG, FULL}

signal resizeTriggered()
signal pocketOpened()
signal pocketClosed()

func setSize(expectedCards: int):

	if expectedCards <= 3:
		size = PocketSize.SMALL
	elif expectedCards <= 6:
		size = PocketSize.MEDIUM
	elif expectedCards <= 12:
		size = PocketSize.BIG
	else:
		size = PocketSize.FULL

func adjustPanel():
	var shapeCenter = positionController.relevantShape.position
	var shapeSize = positionController.relevantShape.shape.size
	var topLeftCorner = shapeCenter - shapeSize/2

	backGroundPanel.position = topLeftCorner
	backGroundPanel.size = shapeSize
	resizeTriggered.emit()

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
	pocketClosed.emit()
	queue_free()
