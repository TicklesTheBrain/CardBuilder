extends Node2D
class_name Game

enum ContainerPurposes {DECK, HAND, PLAY_AREA, DISCARD}

@export var deckManager: DeckManager
@export var enemyDeckManager: DeckManager
@export var enemyDiscard: CardContainer
@export var handManager: CardContainer
@export var playAreaManager: CardContainer
@export var enemyPlayArea: CardContainer
@export var discardManager: CardContainer

@export var energy: GenericResource
@export var damageDealt: GenericResource
@export var damageSuffered: GenericResource

@export var message: String:
	set (value):
		message = value
		messageLabel.text = value

@export var messageLabel: Label
@export var cardDisplayPacked: PackedScene
@export var newCardMarker: Marker2D

@export var drawCardButton: Button
@export var endHandButton: Button
@export var okButton: Button

@export var turnStartDrawCards: int = 3

var player: Actor
var enemy: Actor
var activeActor: Actor
var passiveActor: Actor

class Actor:
	var drawDeck: DeckManager
	var hand: CardContainer
	var discard: CardContainer
	var playArea: CardContainer

func _ready():

	player = Actor.new()
	player.drawDeck = deckManager
	deckManager.buildNewEmptyDeck()
	deckManager.shuffle()
	player.discard = discardManager
	player.hand = handManager
	player.playArea = playAreaManager

	enemy = Actor.new()
	enemy.drawDeck = enemyDeckManager
	enemyDeckManager.buildNewEmptyDeck()
	enemy.playArea = enemyPlayArea
	enemy.discard = enemyDiscard
	enemy.hand = CardContainer.new() as CardContainer
	enemy.hand.maxCards = 0

	Events.requestContext.connect(provideContext)
	Events.newCardDisplayRequested.connect(spawnNewCardDisplay)

	roundLoop()

func provideContext(requestingObject):
	
	var ctxt = GameStateContext.new() as GameStateContext 
	ctxt.drawDeck = activeActor.drawDeck
	ctxt.discard = activeActor.discard
	ctxt.hand = activeActor.hand
	ctxt.playArea = activeActor.playArea
	ctxt.energyResource = energy
	requestingObject.receiveContext(ctxt)

func drawFromDeckToHand():
			
	var topCard = deckManager.drawCard()
	if topCard:		
		handManager.addCard(topCard)

func spawnNewCardDisplay(card: CardData):

	var newCardDisplay = cardDisplayPacked.instantiate() as CardDisplay
	newCardDisplay.setupCardDisplay(card)
	add_child(newCardDisplay)
	newCardDisplay.position = newCardMarker.position
	newCardDisplay.add_to_group("cd")

func addToPlayArea(card: CardData):

	if playAreaManager.checkFull():
		return

	if card.getCost() > energy.amount:
		return

	energy.amount -= card.getCost()	
	
	playAreaManager.addCard(card)
	handManager.removeCard(card)

func enemySingleStep(valueToBeat: int) -> bool:

	if enemyPlayArea.checkFull():
		return false
	if enemyPlayArea.bustCounter.checkIsBusted():
		return false
	print(enemyPlayArea.bustCounter.prevCount, 'valuetobeat', valueToBeat)
	if enemyPlayArea.bustCounter.prevCount > valueToBeat:
	
		return false

	var card = enemyDeckManager.drawCard()
	enemyPlayArea.addCard(card)
	return true

func roundLoop():
	
	## PLAYER TURN SETUP
	message = 'new round started'

	energy.reset()
	activeActor = player
	passiveActor = enemy
	Events.playerTurnStart.emit()

	for i in range(turnStartDrawCards):
		drawFromDeckToHand()

	drawCardButton.disabled = false
	endHandButton.disabled = false
	okButton.disabled = true

	await endHandButton.button_down

	## CLEANUP AT THE END OF PLAYER TURN

	var playedCards = playAreaManager.getAll()
	var defence = playedCards.reduce(func(acc, card): return acc+card.stats.defence, 0)
	var attack = playedCards.reduce(func(acc, card): return acc+card.stats.attack, 0)
	var value = playAreaManager.getTotalValue()
	var busted = playAreaManager.bustCounter.checkIsBusted()
	
	if busted:
		message = "You busted"
	else:	
		message = "Your Value: {value}, Att: {att}, Def: {def}".format({"value": value, 'att': attack, "def": defence})
		
	
	playAreaManager.disposeAll()
	#handManager.disposeAll()

	drawCardButton.disabled = true
	endHandButton.disabled = true

	Events.playerTurnEnd.emit(value, busted)
	

	##ENEMY ACTIONS

	activeActor = enemy
	passiveActor = player

	while (enemySingleStep(value)):
		await get_tree().create_timer(0.75).timeout

	okButton.disabled = false

	await okButton.button_down

	##ROUND RESOLUTION

	if enemyPlayArea.bustCounter.checkIsBusted():
		message = "Enemy busted, you deal {dmg}".format({'dmg': attack})
		damageDealt.amount += attack

	elif enemyPlayArea.bustCounter.prevCount == value:
		message = "It's a draw, no damage dealt"

	elif enemyPlayArea.bustCounter.prevCount > value or busted:
		var enemyAttack = enemyPlayArea.getAll().reduce(func(acc, card): return acc+card.stats.attack, 0)
		message = "Enemy wins with value of {their} against your {val}. You suffer {dmg} damage".format({"their": enemyPlayArea.bustCounter.prevCount, "val": value, "dmg": enemyAttack})
		damageSuffered.amount += enemyAttack


	okButton.disabled = false

	await okButton.button_down

	enemyPlayArea.disposeAll()

	roundLoop()
