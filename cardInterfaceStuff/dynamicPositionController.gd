extends CardPositionController
class_name DynamicPositionController

@export var cardAreas: Array[CollisionShape2D]
@export var cardAreaId: int = 0
@export var minCardCenterDistance: float
@export var maxCardGap: float

func scuttleCards():

	if cards.size() < 1:
		return

	var centerPos = cardAreas[cardAreaId].position
	var areaWidth = cardAreas[cardAreaId].shape.get_rect().size.x
	var cardWidth = cards[0].cardShape.get_children()[0].shape.get_rect().size.x
	var distanceBetweenCards = minCardCenterDistance
	var startingPoint: Vector2

	if cards.size() == 1:
		distanceBetweenCards = 0
	elif (cards.size()-1)*maxCardGap+cards.size()*cardWidth < areaWidth:
		distanceBetweenCards = maxCardGap+cardWidth
	elif cardWidth+(cards.size()-1)*minCardCenterDistance >= areaWidth:
		distanceBetweenCards = minCardCenterDistance
		startingPoint = centerPos - Vector2(areaWidth/2,0) + Vector2(cardWidth/2,0)
	else:
		distanceBetweenCards = (areaWidth - cardWidth) / (cards.size()-1)
	
	var totalCardWidth = cardWidth + distanceBetweenCards*(cards.size()-1)
	if not startingPoint:
		startingPoint = centerPos - Vector2(totalCardWidth/2, 0) + Vector2(cardWidth/2,0)

	var i = 0
	var tween = get_tree().create_tween().set_parallel()

	for card: CardDisplay in cards:
		var cardPosition = startingPoint + Vector2(i*distanceBetweenCards,0)
		i +=1
		tween.tween_property(card,"position", cardPosition, cardMoveTime)

func switchCardArea(newId: int):
	cardAreaId = newId
	scuttleCards()

func resetCardArea():
	switchCardArea(0)


