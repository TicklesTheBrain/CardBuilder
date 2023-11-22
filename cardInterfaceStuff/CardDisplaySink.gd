extends CardPositionController
class_name CardDisplaySink

@export var positionMarker: Marker2D

func scuttleCards():

	for cd in cards:
		var tween = get_tree().create_tween()
		tween.tween_property(cd, "position", positionMarker.position, cardMoveTime)
		tween.tween_callback(cd.queue_free)

	cards.clear()

func setupContainerSpecific():
	logicalContainer.originMarker = positionMarker
			
	