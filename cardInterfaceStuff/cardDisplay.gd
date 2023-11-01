extends Node2D
class_name CardDisplay

@export var cardShape: Area2D
@export var valueTypeLabel: Label
@export var costLabel: Label
@export var cardTextLabel: RichTextLabel
@export var attackLabel: Label
@export var defenceLabel: Label

var cardData: CardData
var mouseOver: bool
var dragged: bool
var mouseOffset = Vector2()
var previousPosition = Vector2()
var inPlayArea = null
var positionController: VariedPositionController

func _ready():
	pass

func setupCardDisplay(data: CardData):
	cardData = data
	valueTypeLabel.text = str(data.value) + data.type
	costLabel.text = str(data.cost) + 'E'
	cardTextLabel.text = data.cardText
	
	if data.stats.attack > 0:
		attackLabel.text = str(data.stats.attack) + 'Att'
	else:
		attackLabel.text = ""
	if data.stats.defence >0:
		defenceLabel.text = str(data.stats.defence) + 'Def'
	else:
		defenceLabel.text = ""

func _process(_delta):
	if dragged:
		position = get_viewport().get_mouse_position() + mouseOffset

func onClick():
	if not dragged and not inPlayArea:
		previousPosition = position
		dragged = true
		mouseOffset = get_viewport().get_mouse_position() - position

func onRelease():
	if dragged:
		dragged = false
		positionController.scuttleCards()

		if inPlayArea != null:			
			inPlayArea.addCard(self)
		else:
			positionController.scuttleCards()
	

	




