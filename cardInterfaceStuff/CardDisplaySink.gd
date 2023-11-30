extends CardPositionController
class_name CardDisplaySink

@export var positionMarker: Marker2D

func scuttleCardsSpecific():	
	for cd in cards:
		var newTween = get_tree().create_tween()
		newTween.tween_property(cd, "position", positionMarker.position, cardMoveTime)
		newTween.tween_callback(cd.queue_free)
		newTween.tween_callback(removeCardDisplay.bind(cd))
		addInterruptableTween(cd, newTween)

func setupContainerSpecific():
	logicalContainer.originMarker = positionMarker

	