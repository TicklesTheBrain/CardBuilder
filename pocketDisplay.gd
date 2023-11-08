extends CanvasLayer
class_name PocketDisplay

@export var animation: AnimationPlayer
@export var positionController: VariedPositionController
@export var infoLabel: Label

func setupPositionController(container: CardContainer):
    positionController.setupNewLogicalContainer(container)

func setupText(text: String):
    infoLabel.text = text

func showPocket():
    animation.play("show")

func hidePocket():
    animation.play("hide")
    await animation.animation_finished
    queue_free()
