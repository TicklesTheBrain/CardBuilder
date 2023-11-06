extends Node2D
class_name CardDisplaySink

@export var container: CardContainer
@export var animationTime: float
@export var positionMarker: Marker2D

func _ready():
	container.cardAdded.connect(showCardRemoval)

func showCardRemoval(card: CardData):
	print('card removal triggered')
	var cds = get_tree().get_nodes_in_group("cd") as Array[CardDisplay]
	for cd in cds:
		if cd.cardData == card:
			var tween = get_tree().create_tween()
			tween.tween_property(cd, "position", positionMarker.position, animationTime)
			tween.tween_callback(cd.queue_free)
			
	