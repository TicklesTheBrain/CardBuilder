extends Node2D
class_name CardDisplay

@export var cardShape: Area2D
@export var valueTypeLabel: Label
@export var costLabel: Label

@export var playTextLabel: RichTextLabel
@export var otherTextLabel: RichTextLabel
@export var discardTextLabel: RichTextLabel

@export var attackLabel: Label
@export var defenceLabel: Label
@export var maxCounter: float

@export var selection: ColorRect

var counter: float = 0
var cardData: CardData
var mouseOver: bool
var dragged: bool
var mouseOffset = Vector2()
var previousPosition = Vector2()
var inPlayArea = null
var positionController: VariedPositionController
var selected = false:
	set(value):
		if value == true:
			selection.visible = true
		else:
			selection.visible = false
		selected = value

func _ready():
	Events.updateAllDisplays.connect(updateCardDisplay)
	Selector.cardSelectionComplete.connect(unselect)

func setupCardDisplay(data: CardData):
	cardData = data
	updateCardDisplay()

func updateCardDisplay():	
	valueTypeLabel.text = str(cardData.getValue()) + cardData.type
	costLabel.text = str(cardData.getCost()) + 'E'

	var playText = cardData.getPlayEffectText()
	if playText != "":
		playTextLabel.text = "[b]Play:[/b] " + playText

	var otherText = cardData.getOtherText()
	if otherText != "":
		otherTextLabel.text = otherText
	
	if cardData.stats.attack > 0:
		attackLabel.text = str(cardData.stats.attack) + 'Att'
	else:
		attackLabel.text = ""
	if cardData.stats.defence >0:
		defenceLabel.text = str(cardData.stats.defence) + 'Def'
	else:
		defenceLabel.text = ""

func _process(delta):

	counter -= delta
	if counter <= 0:
		updateCardDisplay()
		counter = maxCounter

	if dragged:
		position = get_viewport().get_mouse_position() - mouseOffset

func onClick():

	if Selector.selecting:
		if Selector.subjectContainer == cardData.container:
			if selected:
				selected = false
				Selector.removeFromSelection(cardData)
			else:
				selected = true
				Selector.addToSelection(cardData)
		return

	if not dragged and not inPlayArea:
		previousPosition = position
		dragged = true
		mouseOffset = get_viewport().get_mouse_position() - position

func unselect():
	if selected:
		selected = false

func onRelease():
	if dragged:
		dragged = false
		positionController.scuttleCards()

		if inPlayArea != null:			
			inPlayArea.addCard(self)
		else:
			positionController.scuttleCards()
