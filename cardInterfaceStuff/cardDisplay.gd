extends Node2D
class_name CardDisplay

@export var cardShape: Area2D
@export var cardImageRect: TextureRect

@export_group("Detailed Info References")
@export var detailedInfoRoot: PanelContainer
@export var valueLabel: Label
@export var costLabel: Label

@export var conditionalTextLabel: RichTextLabel
@export var valuesModifiersTextLabel: RichTextLabel
@export var costModifiersTextLabel: RichTextLabel
@export var attackModifiersTextLabel: RichTextLabel
@export var defenceModifiersTextLabel: RichTextLabel
@export var onPlayTextLabel: RichTextLabel
@export var onLoseTextLabel: RichTextLabel
@export var onWinTextLabel: RichTextLabel
@export var onBustTextLabel: RichTextLabel
@export var endRoundTextLabel: RichTextLabel
@export var onDrawTextLabel: RichTextLabel
@export var startMatchTextLabel: RichTextLabel

@export var attackLabel: Label
@export var defenceLabel: Label
@export var forceUpdateSeconds: float

@export var selectedColor: Color

var previousZOrder: int
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
			cardImageRect.self_modulate = selectedColor
		else:
			cardImageRect.self_modulate = Color.WHITE
		selected = value

func _ready():
	Events.updateAllDisplays.connect(updateCardDisplay)
	InputLord.cardSelectionComplete.connect(unselect)

func updateCardImage(data: CardData):
	await CardImageMaker.getCardImage(data, receiveCardImage)

func setupCardDisplay(data: CardData):
	cardData = data
	cardData.announceDestroy.connect(queue_free)
	updateCardDisplay()
	updateCardImage(data)

func receiveCardImage(image: Texture2D):
	cardImageRect.texture = image

func updateCardDisplay(dataToShow: CardData = cardData):

	if graftToShow:
		dataToShow = graftToShow

	valueLabel.text = str(dataToShow.getValue()) + ' ' + dataToShow.type.getStringType()
	costLabel.text = str(dataToShow.getCost())	

	updateAllTextFields(dataToShow)
	
	if dataToShow.getAttack() > 0:
		attackLabel.text = str(dataToShow.getAttack()) + 'A'
	else:
		attackLabel.text = ""
	if dataToShow.getDefence() >0:
		defenceLabel.text = str(dataToShow.getDefence()) + 'D'
	else:
		defenceLabel.text = ""

func updateAllTextFields(dataToShow: CardData):

	var effectDict = dataToShow.getEffectTextDictionary()

	updateTextField(onPlayTextLabel, effectDict.onPlay, "[b]Play:[/b] ")
	updateTextField(conditionalTextLabel, dataToShow.getPlayConditionalText())
	updateTextField(costModifiersTextLabel, dataToShow.cost.getText())
	updateTextField(valuesModifiersTextLabel, dataToShow.value.getText())
	updateTextField(attackModifiersTextLabel, dataToShow.attack.getText())
	updateTextField(defenceModifiersTextLabel, dataToShow.defence.getText())
	updateTextField(onLoseTextLabel, effectDict.onLose, "[b]Lose:[/b] ")
	updateTextField(onWinTextLabel, effectDict.onWin, "[b]Win:[/b] ")
	updateTextField(onBustTextLabel, effectDict.onBust, "[b]Bust:[/b] ")
	updateTextField(endRoundTextLabel, effectDict.endRound, "[b]End:[/b] ")
	updateTextField(onDrawTextLabel, effectDict.onDraw, "[b]Draw:[/b] ")
	updateTextField(startMatchTextLabel, effectDict.startMatch, "[b]Start:[/b] ")

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

func showDetailed():
	detailedInfoRoot.visible = true
	previousZOrder = z_index
	z_index = 100

func hideDetailed():
	detailedInfoRoot.visible = false
	z_index = previousZOrder

func updateTextField(textFieldToFormat: RichTextLabel, newText: String, prefix: String = ""):
	if newText != "":
		textFieldToFormat.visible = true
		textFieldToFormat.text = prefix + newText
	else:
		textFieldToFormat.text = ""
		textFieldToFormat.visible = false
