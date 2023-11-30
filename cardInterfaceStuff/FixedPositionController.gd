extends CardPositionController
class_name FixedPositionController

@export var posCollections: Array[Node2D]

func scuttleCardsSpecific():

	if cards.size() < 1:
		return

	var i = 0
	var currentCollection = posCollections[cards.size()-1].get_children()
	
	for card: CardDisplay in cards:
		var newMarker = currentCollection[i]
		i +=1
		var newTween = get_tree().create_tween()
		newTween.tween_property(card,"position", newMarker.position, cardMoveTime)
		addInterruptableTween(card, newTween)


