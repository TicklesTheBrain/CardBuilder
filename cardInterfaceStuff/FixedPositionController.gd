extends CardPositionController
class_name FixedPositionController

@export var posCollections: Array[Node2D]

func scuttleCards():

	if cards.size() < 1:
		return

	var i = 0
	var currentCollection = posCollections[cards.size()-1].get_children()
	var tween = get_tree().create_tween().set_parallel()

	for card: CardDisplay in cards:
		var newMarker = currentCollection[i]
		i +=1
		tween.tween_property(card,"position", newMarker.position, cardMoveTime)


