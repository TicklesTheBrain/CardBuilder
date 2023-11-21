extends CardPositionController
class_name DynamicPositionController

@export var cardAreas: Array[CollisionShape2D]
@export var cardAreaId: int = 0:
	set (newVal):
		relevantShape = cardAreas[newVal]
		cardAreaId = newVal
@export var minCardCenterDistance: float
@export var maxCardGap: float
@export var multipleRows: bool = false
@export var rowGap: float = 25

var relevantShape: CollisionShape2D

func scuttleCards():

	if cards.size() < 1:
		return

	var numberOfRows
	var areaHeight = relevantShape.shape.get_rect().size.y
	var areaWidth = relevantShape.shape.get_rect().size.x
	var cardHeight = cards[0].cardShape.get_children()[0].shape.get_rect().size.y #TODO: this is fucking ugly
	var cardsInRows = [cards]
	
	if multipleRows:
		var spaceWithoutFirstRow = areaHeight - cardHeight
		numberOfRows = floor(spaceWithoutFirstRow/(cardHeight+rowGap))+1
		var cardsPerRow = ceil(cards.size()/numberOfRows)
		cardsInRows = []
		var c = 0
		for i in range(numberOfRows):
			var newRow = []
			for ci in range(cardsPerRow):
				if c > cards.size()-1:
					break
				newRow.push_back(cards[c])
				c+=1
			cardsInRows.push_back(newRow)

	var centerPos = relevantShape.position
	var totalHeight = (cardsInRows.size()-1)*(cardHeight+rowGap)+cardHeight
	var firstRowCenter = centerPos-Vector2(0,totalHeight/2-cardHeight/2)
	var r = 0
	for row in cardsInRows:
		var rowCenter = firstRowCenter+r*Vector2(0,cardHeight+rowGap)
		scuttleOneRow(row, rowCenter, areaWidth)
		r+=1
	

func scuttleOneRow(rowCards, centerPos: Vector2, areaWidth: float):

	if rowCards.size() == 0:
		return

	var cardWidth = rowCards[0].cardShape.get_children()[0].shape.get_rect().size.x
	var distanceBetweenCards = minCardCenterDistance
	var startingPoint: Vector2

	if rowCards.size() == 1:
		distanceBetweenCards = 0
	elif (rowCards.size()-1)*maxCardGap+rowCards.size()*cardWidth < areaWidth:
		distanceBetweenCards = maxCardGap+cardWidth
	elif cardWidth+(rowCards.size()-1)*minCardCenterDistance >= areaWidth:
		distanceBetweenCards = minCardCenterDistance
		startingPoint = centerPos - Vector2(areaWidth/2,0) + Vector2(cardWidth/2,0)
	else:
		distanceBetweenCards = (areaWidth - cardWidth) / (rowCards.size()-1)
	
	var totalCardWidth = cardWidth + distanceBetweenCards*(rowCards.size()-1)
	if not startingPoint:
		startingPoint = centerPos - Vector2(totalCardWidth/2, 0) + Vector2(cardWidth/2,0)

	var i = 0
	var tween = get_tree().create_tween().set_parallel()

	for card: CardDisplay in rowCards:
		var cardPosition = startingPoint + Vector2(i*distanceBetweenCards,0)
		i +=1
		tween.tween_property(card,"position", cardPosition, cardMoveTime)


func switchCardArea(newId: int):
	cardAreaId = newId
	scuttleCards()

func resetCardArea():
	switchCardArea(0)


