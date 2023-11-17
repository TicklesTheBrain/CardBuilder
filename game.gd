extends Node2D
class_name Game

enum ContainerPurposes {DECK, HAND, PLAY_AREA, DISCARD}

@export var loggerLevel: int = 5
@export var deckManager: DeckManager
@export var enemyDeckManager: DeckManager
@export var enemyDiscard: CardContainer
@export var handManager: CardContainer
@export var playAreaManager: CardContainer
@export var enemyPlayArea: CardContainer
@export var discardManager: CardContainer

@export var playAreaPositionController: DynamicPositionController
@export var enemyPlayAreaPositionController: DynamicPositionController

@export var pocketPacked: PackedScene
var pocketRefs = {}

@export var energy: GenericResource
@export var startTurnCardDraw: GenericResource
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
	
	Logger.printLevel = loggerLevel

	player = Actor.new()
	player.drawDeck = deckManager
	deckManager.buildCardsFromTemplate()
	deckManager.shuffle()
	player.discard = discardManager
	player.hand = handManager
	player.playArea = playAreaManager

	enemy = Actor.new()
	enemy.drawDeck = enemyDeckManager
	enemyDeckManager.buildCardsFromTemplate()
	enemy.playArea = enemyPlayArea
	enemy.discard = enemyDiscard
	enemy.hand = CardContainer.new() as CardContainer
	enemy.hand.maxCards = 0

	Events.requestContext.connect(provideContext)
	Events.newCardDisplayRequested.connect(spawnNewCardDisplay)
	Events.requestNewPocket.connect(makeNewPocket)
	Events.requestClosePocket.connect(cleanUpPocket)
	Events.orphanedCardDisplay.connect(reparentCardDisplay)

	deckManager.triggerAll(CardEffect.triggerType.START_MATCH)

	roundLoop()

func makeContext() -> GameStateContext:
	var ctxt = GameStateContext.new() as GameStateContext 
	ctxt.drawDeck = activeActor.drawDeck
	ctxt.discard = activeActor.discard
	ctxt.hand = activeActor.hand
	ctxt.playArea = activeActor.playArea
	ctxt.energyResource = energy
	ctxt.cardDraw = startTurnCardDraw
	return ctxt

func provideContext(requestingObject):		
	requestingObject.receiveContext(makeContext())

func makeNewPocket(pocketText: String, receivingMethod: Callable):

	var newPocket = pocketPacked.instantiate() as PocketDisplay
	var pocketContainer = CardContainer.new()
	add_child(pocketContainer)
	newPocket.setupPositionController(pocketContainer)
	newPocket.setupText(pocketText)
	add_child(newPocket)

	pocketRefs[pocketContainer] = newPocket
	newPocket.showPocket()
	receivingMethod.call(pocketContainer)

func cleanUpPocket(cardContainer: CardContainer):
	
	Logger.log(['cleanup pocket started', cardContainer], 3)
	var pocket = pocketRefs[cardContainer]
	pocket.hidePocket()
	cardContainer.queue_free()
	pocketRefs.erase(cardContainer)

func reparentCardDisplay(cd: CardDisplay):
	cd.get_parent().remove_child(cd)
	add_child(cd)

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

	if not card.checkPlayConditionals():
		return

	energy.amount -= card.getCost()	
	
	handManager.removeCard(card)
	playAreaManager.addCard(card)

func enemySingleStep(valueToBeat: int) -> bool:

	#TODO: Drawing too many cards when player busted 
	if enemyPlayArea.checkFull():
		return false
	if enemyPlayArea.bustCounter.checkIsBusted():
		return false
	print(enemyPlayArea.bustCounter.prevCount, 'valuetobeat', valueToBeat)
	if enemyPlayArea.bustCounter.prevCount > valueToBeat:
	
		return false

	enemyPlayTopCard()
	return true

func enemyPlayTopCard():
	var card = enemyDeckManager.drawCard()
	enemyPlayArea.addCard(card)


func roundLoop():
	
	## PLAYER TURN SETUP
	message = 'new round started'

	energy.reset()
	startTurnCardDraw.reset()
	playAreaPositionController.resetCardArea()
	enemyPlayAreaPositionController.resetCardArea()

	activeActor = player
	passiveActor = enemy
	enemyPlayTopCard()
	Events.playerTurnStart.emit()

	for i in range(startTurnCardDraw.amount):
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
		
	
	playAreaPositionController.switchCardArea(1)
	enemyPlayAreaPositionController.switchCardArea(1)
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
	playAreaManager.disposeAll()

	##ROUND RESOLUTION

	if enemyPlayArea.bustCounter.checkIsBusted():
		message = "Enemy busted, you deal {dmg}".format({'dmg': attack})
		await playAreaManager.triggerAll(CardEffect.triggerType.WIN)
		damageDealt.amount += attack

	elif enemyPlayArea.bustCounter.prevCount == value:
		message = "It's a draw, no damage dealt"

	elif enemyPlayArea.bustCounter.prevCount > value or busted:
		var enemyAttack = enemyPlayArea.getAll().reduce(func(acc, card): return acc+card.stats.attack, 0)
		message = "Enemy wins with value of {their} against your {val}. You suffer {dmg} damage".format({"their": enemyPlayArea.bustCounter.prevCount, "val": value, "dmg": enemyAttack})
		if busted:
			await playAreaManager.triggerAll(CardEffect.triggerType.BUST)
		else:
			await playAreaManager.triggerAll(CardEffect.triggerType.LOSE)
		damageSuffered.amount += enemyAttack

	else:
		message = "You win with value of {val} against their {their}. They suffer {dmg} damage".format({"their": enemyPlayArea.bustCounter.prevCount, "val": value, "dmg": attack})
		await playAreaManager.triggerAll(CardEffect.triggerType.WIN)
		damageDealt.amount += attack

	await playAreaManager.triggerAll(CardEffect.triggerType.END_ROUND)

	okButton.disabled = false

	await okButton.button_down

	enemyPlayArea.disposeAll()

	roundLoop()
