extends Area2D

@export var positionController: VariedPositionController
@export var shape: CollisionShape2D

func _on_area_exited(area:Area2D):
	if area.get_parent() is CardDisplay:
		area.get_parent().inPlayArea = null

func _on_area_entered(area:Area2D):
	if area.get_parent() is CardDisplay:
		area.get_parent().inPlayArea = self

func addCard(card: CardDisplay):
	get_parent().addToPlayArea(card.cardData)
