extends Area2D

@export var positionController: CardPositionController
@export var shape: CollisionShape2D
var cardsInPlayArea: Array[CardDisplay] = []

func _ready():
	InputLord.cardDragReleased.connect(addCard)

func _on_area_exited(area:Area2D):
	if area.get_parent() is CardDisplay:
		cardsInPlayArea.erase(area.get_parent())

func _on_area_entered(area:Area2D):
	if area.get_parent() is CardDisplay:
		cardsInPlayArea.push_back(area.get_parent())

func addCard(card: CardDisplay):
	if cardsInPlayArea.has(card):
		get_parent().addToPlayArea(card.cardData)
