extends Node2D
class_name CardDisplay

enum BackTypes {RED, BLUE}

@export var cardShape: Area2D
@export var cardImageRect: TextureRect
@export var showDetailsCooldown: float = 0.1
var shouldShowDetailed: bool = false
@onready var topControl = cardImageRect

@export_group("Shadow stuff")
@export var maxShadowOffset: Vector2
@export var minShadowOffset: Vector2 = Vector2(0,0)
@export var shadowOffsetGrowTime: float
@export var shadowOffsetShrinkTime: float
@export var offsetNode: Node2D
var prevPosition: Vector2 
var shadowTimer: float = 0
var shadowGrow: bool = false:
	set(new):
		if new != shadowGrow:
			shadowTimer = 0
		shadowGrow = new

@export_group("Card Back Stuff")
@export var backsRed: Array[Texture2D]
@export var backsBlue: Array[Texture2D]

@export_group("Detailed Info References")
@export var detailedInfoRoot: Control
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

var selectionNode
var prevAttack: int
var prevValue: String
var prevDefence: int
var prevCost: int
var prevRevealed: bool

var waitingForCardImage: bool
signal cardImageReceived()

var broughtToFront: bool
var regularZOrder: int = 0
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
			selectionNode.self_modulate = selectedColor
		else:
			selectionNode.self_modulate = Color.WHITE
		selected = value

func _ready():
	Events.gameStateChange.connect(maybeUpdateNeeded)
	InputLord.cardSelectionComplete.connect(unselect)
	if cardImageRect != null:
		selectionNode = cardImageRect

func getCardBack(type: BackTypes) -> Texture2D:
	match type:
		BackTypes.RED:
			return backsRed.pick_random()
		BackTypes.BLUE:
			return backsBlue.pick_random()
	return null

func updateCardImage(data: CardData = cardData):
	if data.revealed:		
		waitingForCardImage = true
		await CardImageMaker.getCardImage(data, receiveCardImage)
	else:		
		if waitingForCardImage:
			await cardImageReceived
		cardImageRect.texture = getCardBack(data.cardBack)

func setupCardDisplay(data: CardData):
	cardData = data
	cardData.announceDestroy.connect(queue_free)
	cardData.revealChange.connect(maybeUpdateNeeded)
	updateCardDetails()
	updateCardImage(data)

func receiveCardImage(image: Texture2D):
	waitingForCardImage = false
	cardImageRect.texture = image
	cardImageReceived.emit()

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

func _process(delta):
	shadowTimer += delta
	if dragged:
		position = get_viewport().get_mouse_position() - mouseOffset
		shadowGrow = true
	else:
		shadowGrow = false

	if shadowGrow:
		offsetNode.position = clamp(lerp(minShadowOffset, maxShadowOffset, shadowTimer / shadowOffsetGrowTime), minShadowOffset, maxShadowOffset)
	else:
		offsetNode.position = clamp(lerp(offsetNode.position, minShadowOffset, shadowTimer / shadowOffsetShrinkTime), minShadowOffset, maxShadowOffset)


func onClick():
	InputLord.cardClicked.emit(self)

func onMouseEnterCard():
	#print(name, ' mouse enter card')
	InputLord.cardMouseOver.emit(self)

func onMouseLeaveCard():
	#print(name, ' mouse leave card')
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
	updateCardDetails()
	print('new graft', graftToShow)
	updateCardImage(graftToShow)

func hideGraft():
	graftToShow = null
	updateCardDetails()
	updateCardImage()

func showDetailed():
	shouldShowDetailed = true
	await get_tree().create_timer(showDetailsCooldown).timeout
	if shouldShowDetailed:
		if cardData.revealed:
			detailedInfoRoot.visible = true
		bringToFront()

func hideDetailed():
	shouldShowDetailed = false
	await get_tree().create_timer(showDetailsCooldown).timeout
	if not shouldShowDetailed:
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
	updateZ()

func bringBackFromFront():
	broughtToFront = false
	updateZ()

func setRegularZIndex(newIndex: int):
	regularZOrder = newIndex
	updateZ()

func updateZ():
	if broughtToFront:
		z_index = 100
	else:
		z_index = regularZOrder
