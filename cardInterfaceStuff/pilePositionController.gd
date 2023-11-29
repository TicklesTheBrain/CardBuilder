extends CardPositionController
class_name PilePositionController

@export var pileCenter: Marker2D
@export var rotationPlusMinus: float

var rotations = {}

func scuttleCards():

	if cards.size() < 1:
		rotations = {}
		return

	for card in cards:
		if not rotations.has(card):
			rotations[card] = getNewRotation()

	for card in rotations.keys():
		if not cards.has(card):
			rotations.erase(card)

	activeTween = get_tree().create_tween().set_parallel()
	for card in cards:
		activeTween.tween_property(card, "position", pileCenter.position, cardMoveTime)
		activeTween.tween_property(card, "rotation_degrees", rotations[card], cardMoveTime)

func getNewRotation():
	return randf_range(-rotationPlusMinus, rotationPlusMinus)
