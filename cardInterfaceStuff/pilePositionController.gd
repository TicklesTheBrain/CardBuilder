extends CardPositionController
class_name PilePositionController

@export var pileCenter: Marker2D
@export var positionDriftX: float
@export var positionDriftY: float
@export var rotationDrift: float
@export var shufflePositionDriftX: float
@export var shufflePositionDriftY: float
@export var shuffleRotationDrift: float
@export var shuffleTime: float
@export var shuffleTimeDrift: float

var rotations = {}
var positions = {}

#TODO: scuttleSpecific and ShuffleSpecific to fix mismatch between visual and logic after shuffling

func scuttleCardsSpecific():

	if cards.size() < 1:
		rotations = {}
		positions = {}
		return

	for card in cards:
		if not rotations.has(card):
			rotations[card] = getNewRotation()
		if not positions.has(card):
			positions[card] = getNewPosition()

	for card in rotations.keys():
		if not cards.has(card):
			rotations.erase(card)

	for card in positions.keys():
		if not cards.has(card):
			positions.erase(card)

	for card in cards:
		var newTween = get_tree().create_tween().set_parallel()
		newTween.tween_property(card, "position", positions[card], cardMoveTime)
		newTween.tween_property(card, "rotation_degrees", rotations[card], cardMoveTime)
		addInterruptableTween(card, newTween)

func getNewRotation():
	return randf_range(-rotationDrift, rotationDrift)

func getNewPosition():
	return pileCenter.position + Vector2(Vector2(randf_range(-positionDriftX, positionDriftX), randf_range(-positionDriftY, positionDriftY)))

func showShuffleSpecific():

	#First let's set up a new rotation and position for each card
	for display in rotations.keys():
		rotations[display] = getNewRotation()

	for display in positions.keys():
		positions[display] = getNewPosition()

	#Second let's set up a shuffle out parameters for each card and make tweeners	
	for card in cards:
		var outTime = shuffleTime/2 + randf_range(0, shuffleTimeDrift)
		var outPos = pileCenter.position + Vector2(randf_range(-shufflePositionDriftX, shufflePositionDriftX), randf_range(-shufflePositionDriftY, shufflePositionDriftY))
		var outRot = card.rotation + randf_range(-shuffleRotationDrift, shuffleRotationDrift)
		var inTime = shuffleTime - outTime
		assert(inTime > 0)
		var newTween = get_tree().create_tween()
		newTween.tween_property(card, "position", outPos, outTime)
		newTween.parallel().tween_property(card, "rotation_degrees", outRot, outTime)
		newTween.tween_property(card, "position", positions[card], inTime)
		newTween.parallel().tween_property(card, "rotation_degrees", rotations[card], inTime)
		addMandatoryTween(card, newTween)
		
		


