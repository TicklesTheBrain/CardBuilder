extends Node2D
class_name CardDisplay

enum BackTypes {RED, BLUE}

@export var cardShape: Area2D
@export var cardImageRect: TextureRect

@export_group("Card Back Stuff")
@export var backsRed: Array[Texture2D]
@export var backsBlue: Array[Texture2D]

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

@export var selectedColor: Color

var tweens = {}

var prevAttack: int
var prevValue: String
var prevDefence: int
var prevCost: int
var prevRevealed: bool

var broughtToFront: bool
var previousZOrder: int
var graftToShow: CardData
var cardData: CardData
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
	Events.gameStateChange.connect(maybeUpdateNeeded)
	InputLord.cardSelectionComplete.connect(unselect)

func getCardBack(type: BackTypes) -> Texture2D:
	match type:
		BackTypes.RED:
			return backsRed.pick_random()
		BackTypes.BLUE:
			return backsBlue.pick_random()
	return null

func updateCardImage(data: CardData):
	if data.revealed:
		await CardImageMaker.getCardImage(data, receiveCardImage)
	else:
		cardImageRect.texture = getCardBack(data.cardBack)

func setupCardDisplay(data: CardData):
	cardData = data
	cardData.announceDestroy.connect(queue_free)
	cardData.revealChange.connect(maybeUpdateNeeded)
	updateCardDetails()
	updateCardImage(data)

func receiveCardImage(image: Texture2D):
	cardImageRect.texture = image

func maybeUpdateNeeded(dataToShow: CardData = cardData):

	var currValue = str(dataToShow.getValue()) + ' ' + dataToShow.type.getStringType()
	var currCost = dataToShow.getCost()
	var currAttack = dataToShow.getAttack()
	var currDefence = dataToShow.getDefence()
	var currRevealed = dataToShow.revealed	

	if currValue != prevValue or currCost != prevCost or currAttack != prevAttack or currDefence != prevDefence or prevRevealed != currRevealed:
		updateCardImage(dataToShow)
		updateCardDetails(dataToShow)

func updateCardDetails(dataToShow: CardData = cardData):

	if graftToShow:
		dataToShow = graftToShow

	prevRevealed = dataToShow.revealed

	var currValue = str(dataToShow.getValue()) + ' ' + dataToShow.type.getStringType()
	prevValue = currValue
	valueLabel.text = currValue

	var currCost = dataToShow.getCost()
	prevCost = currCost
	costLabel.text = str(currCost)
	
	var currAttack = dataToShow.getAttack()
	prevAttack = currAttack

	
	if currAttack > 0:
		attackLabel.text = str(currAttack) + 'A'
	else:
		attackLabel.text = ""

	var currDefence = dataToShow.getDefence()
	prevDefence = currDefence

	if currDefence >0:
		defenceLabel.text = str(currDefence) + 'D'
	else:
		defenceLabel.text = ""

	updateAllTextFields(dataToShow)
			
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

func _process(_delta):

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
	if cardData.revealed:
		detailedInfoRoot.visible = true
	bringToFront()

func hideDetailed():
	detailedInfoRoot.visible = false
	bringBackFromFront()

func updateTextField(textFieldToFormat: RichTextLabel, newText: String, prefix: String = ""):
	if newText != "":
		textFieldToFormat.visible = true
		textFieldToFormat.text = prefix + newText
	else:
		textFieldToFormat.text = ""
		textFieldToFormat.visible = false

func bringToFront():
	broughtToFront = true
	previousZOrder = z_index
	z_index = 100

func bringBackFromFront():
	broughtToFront = false
	z_index = previousZOrder

func setRegularZIndex(newIndex: int):
	if broughtToFront:
		previousZOrder = newIndex
	else:
		z_index = newIndex


	
