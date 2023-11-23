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
@export var forceUpdateSeconds: float

@export var selection: ColorRect

var graftToShow: CardData
var counter: float = 0
var cardData: CardData
var mouseOver: bool
var dragged: bool
var mouseOffset = Vector2()
var previousPosition = Vector2()
var inPlayArea = null
var positionController: CardPositionController
var selected = false:
	set(value):
		if value == true:
			selection.visible = true
		else:
			selection.visible = false
		selected = value

func _ready():
	Events.updateAllDisplays.connect(updateCardDisplay)
	InputLord.cardSelectionComplete.connect(unselect)

func setupCardDisplay(data: CardData):
	cardData = data
	cardData.announceDestroy.connect(queue_free)
	updateCardDisplay()

func updateCardDisplay(dataToShow: CardData = cardData):

	if graftToShow:
		dataToShow = graftToShow

	valueTypeLabel.text = str(dataToShow.getValue()) + dataToShow.type.getStringType()
	costLabel.text = str(dataToShow.getCost()) + 'E'

	var playText = dataToShow.getPlayEffectText()
	if playText != "":
		playTextLabel.text = "[b]Play:[/b] " + playText

	var otherText = dataToShow.getOtherText()
	if otherText != "":
		otherTextLabel.text = otherText
	
	if dataToShow.stats.attack > 0:
		attackLabel.text = str(dataToShow.stats.attack) + 'Att'
	else:
		attackLabel.text = ""
	if dataToShow.stats.defence >0:
		defenceLabel.text = str(dataToShow.stats.defence) + 'Def'
	else:
		defenceLabel.text = ""

func _process(delta):

	counter -= delta
	if counter <= 0:
		updateCardDisplay()
		counter = forceUpdateSeconds

	if dragged:
		position = get_viewport().get_mouse_position() - mouseOffset

func onClick():
	InputLord.cardClicked.emit(self)

func onMouseEnterCard():
	InputLord.cardMouseOver.emit(self)

func onMouseLeaveCard():
	InputLord.cardMouseOverExit.emit(self)

func unselect():	
	selected = false

func onRelease():
	if dragged:
		InputLord.cardDragReleased.emit(self)

func startDrag():
	previousPosition = position
	dragged = true
	mouseOffset = get_viewport().get_mouse_position() - position

func endDrag():
	dragged = false

func select():
	selected = true

func showGraft(graft: CardData):
	graftToShow = cardData.duplicateSelf().addCardGraft(graft)
	print('new graft', graftToShow)

func hideGraft():
	graftToShow = null
