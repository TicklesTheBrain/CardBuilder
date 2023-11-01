extends Node2D

@export var deckManager: DeckManager
@export var enemyDeckManager: DeckManager
@export var handManager: CardContainer
@export var playAreaManager: CardContainer
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
@export var handPositionController: VariedPositionController

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
	enemy.playArea = playAreaManager
	enemy.discard = CardContainer.new() as CardContainer
	enemy.discard.maxCards = 0
	enemy.hand = CardContainer.new() as CardContainer
	enemy.hand.maxCards = 0

	activeActor = player
	passiveActor = enemy

	energy.reset()
	Events.requestContext.connect(provideContext)
	Events.newCardDisplayRequested.connect(spawnNewCardDisplay)

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

	if card.cost > energy.amount:
		return

	energy.amount -= card.cost	
	
	playAreaManager.addCard(card)
	handManager.removeCard(card)

func endHand():

	const waitInterval = 1.0

	var playedCards = playAreaManager.getAll()
	var defence = playedCards.reduce(func(acc, card): return acc+card.stats.defence, 0)
	var attack = playedCards.reduce(func(acc, card): return acc+card.stats.attack, 0)
	var value = playedCards.reduce(func(acc, card): return acc+card.value, 0)
	var busted = playAreaManager.bustCounter.checkIsBusted()
	var enemyWin: bool = false

	if busted:
		message = "You busted"
	else:	
		message = "Your Value: {value}, Att: {att}, Def: {def}".format({"value": value, 'att': attack, "def": defence})

	playAreaManager.removeAll()
	for card in playedCards:
		discardManager.addCard(card)

	await get_tree().create_timer(waitInterval).timeout

	if not busted:
		enemyDeckManager.shuffle()

		while (not playAreaManager.checkFull() and not playAreaManager.bustCounter.checkIsBusted() and playAreaManager.bustCounter.prevCount < value):
			var topCard = enemyDeckManager.getTop()
			enemyDeckManager.removeCard(topCard)
			playAreaManager.addCard(topCard)
			await get_tree().create_timer(waitInterval).timeout

		if playAreaManager.bustCounter.checkIsBusted():
			message = "Enemy busted, you deal {dmg}".format({'dmg': attack})
			damageDealt.amount += attack
			

		elif playAreaManager.bustCounter.prevCount == value:
			message = "It's a draw, no damage dealt"

		elif playAreaManager.bustCounter.prevCount > value:
			message = "Enemy wins with value of {their} against your {val}".format({"their": playAreaManager.bustCounter.prevCount, "val": value})
			enemyWin = true
			
		await get_tree().create_timer(waitInterval).timeout
	
	if enemyWin or busted:
		var randomDamage = randi_range(1,5)
		damageSuffered.amount += randomDamage
		message = "enemy deals you {dmg} damage".format({"dmg": randomDamage})

	var enemyPlayedCards = playAreaManager.getAll()
	playAreaManager.removeAll()
	var cds = get_tree().get_nodes_in_group("cd") as Array[CardDisplay]
	for card in enemyPlayedCards:
		enemyDeckManager.addCard(card)
		var cd = cds.filter(func(display): return display.cardData == card)[0]
		cd.queue_free()

	energy.reset()

