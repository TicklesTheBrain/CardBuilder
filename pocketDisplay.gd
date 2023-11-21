extends CanvasLayer
class_name PocketDisplay

@export var animation: AnimationPlayer
@export var positionController: CardPositionController
@export var infoLabel: Label

signal pocketOpened
signal pocketClosed

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
