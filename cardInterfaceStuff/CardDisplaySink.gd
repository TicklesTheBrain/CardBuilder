extends CardPositionController
class_name CardDisplaySink

@export var positionMarker: Marker2D

func scuttleCards():
	activeTween = get_tree().create_tween().set_parallel()
	for cd in cards:
		activeTween.tween_property(cd, "position", positionMarker.position, cardMoveTime)
		activeTween.tween_callback(cd.queue_free)
		activeTween.tween_callback(removeCardDisplay.bind(cd))

func setupContainerSpecific():
	logicalContainer.originMarker = positionMarker

	