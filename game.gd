extends Node2D
class_name Game

@export var loggerLevel: int = 5

@export var playAreaPositionController: DynamicPositionController
@export var enemyPlayAreaPositionController: DynamicPositionController

@export var damageDealt: GameResource
@export var damageSuffered: GameResource

@export var message: String:
	set (value):
		message = value
		messageLabel.text = value

@export var messageLabel: Label
@export var cardDisplayPacked: PackedScene
@export var cardGraftDisplayPacked: PackedScene

@export var drawCardButton: Button
@export var endHandButton: Button
@export var okButton: Button

@export var player: Actor
@export var enemy: Actor

var activeActor: Actor
var passiveActor: Actor

func _ready():
	
	#TODO: FInish logger
	Logger.printLevel = loggerLevel

	Events.requestContext.connect(provideContext)
	Events.startMatch.emit()

	roundLoop()

func makeContext() -> GameStateContext:
	var ctxt = GameStateContext.new() as GameStateContext 
	ctxt.player = player
	ctxt.enemy = enemy
	ctxt.activeActor = activeActor
	ctxt.passiveActor = passiveActor
	return ctxt

func provideContext(requestingObject):		
	requestingObject.receiveContext(makeContext())

func drawFromDeckToHand():			
	var topCard = player.deck.drawCard()
	if topCard:		
		player.hand.addCard(topCard)

func addToPlayArea(card: CardData):

	if player.playArea.checkFull():
		return

	if card.getCost() > player.energy.amount:
		return

	if not card.checkPlayConditionals():
		return

	player.energy.amount -= card.getCost()	
	
	player.hand.removeCard(card)
	player.playArea.addCard(card)

func enemySingleStep(valueToBeat: int) -> bool:

	#TODO: Drawing too many cards when player busted 
	if enemy.playArea.checkFull():
		return false
	if enemy.playArea.bustCounter.checkIsBusted():
		return false
	print(enemy.playArea.bustCounter.prevCount, 'valuetobeat', valueToBeat)
	if enemy.playArea.bustCounter.prevCount > valueToBeat:
	
		return false

	enemyPlayTopCard()
	return true

func enemyPlayTopCard():
	var card = enemy.deck.drawCard()
	enemy.playArea.addCard(card)

func askToShowDetailed(cardDisplay: CardDisplay, addExitDelegate: Callable):
	cardDisplay.showDetailed()
	addExitDelegate.call(cardDisplay, cardDisplay.hideDetailed)

func roundLoop():
	
	## PLAYER TURN SETUP
	message = 'New round started'

	InputLord.addDragContainers(player.hand)
	InputLord.addMouseOverDelegate(player.hand, askToShowDetailed)
	InputLord.addMouseOverDelegate(player.playArea, askToShowDetailed)
	player.resetResources()
	playAreaPositionController.resetCardArea()
	enemyPlayAreaPositionController.resetCardArea()

	activeActor = player
	passiveActor = enemy
	enemyPlayTopCard()
	Events.playerTurnStart.emit()

	for i in range(player.cardsPerTurn.amount):
		drawFromDeckToHand()

	drawCardButton.disabled = false
	endHandButton.disabled = false
	okButton.disabled = true

	await endHandButton.button_down

	## CLEANUP AT THE END OF PLAYER TURN
	playAreaPositionController.switchCardArea(1)
	enemyPlayAreaPositionController.switchCardArea(1)
	InputLord.removeDragContainers(player.hand)

	drawCardButton.disabled = true
	endHandButton.disabled = true

	var playerValue = player.playArea.bustCounter.count
	var playerBusted = player.playArea.bustCounter.checkIsBusted()

	Events.playerTurnEnd.emit(playerValue, playerBusted)	

	##ENEMY ACTIONS

	activeActor = enemy
	passiveActor = player

	while (enemySingleStep(playerValue)):
		await get_tree().create_timer(0.75).timeout

	okButton.disabled = false

	message = "Enemy Finished playing"

	await okButton.button_down
	
	##ROUND RESOLUTION
	var winner: Actor
	var loser: Actor
	var bust: bool

		#Determine winner/loser
	playerValue = player.playArea.bustCounter.count #Update this in case when some enemy effects might alter player value
	var enemyValue = enemy.playArea.bustCounter.count
	if player.playArea.bustCounter.checkIsBusted():
		winner = enemy
		loser = player
		bust = true
	elif enemy.playArea.bustCounter.checkIsBusted():
		winner = player
		loser = enemy
		bust = true
	elif enemyValue> playerValue:
		winner = enemy
		loser = player
	elif enemyValue < playerValue:
		winner = player
		loser = enemy

	if winner:
		
		#Show info about the values
		var valueString = "You win, {playerValue} vs. {enemyValue}. {whoBusted}"
		if winner != player:
			valueString = "You lose, {playerValue} vs {enemyValue}. {whoBusted}"
		
		var whoBustedString = ""
		if bust:
			whoBustedString = "Enemy busted" if winner == player else "You busted"

		message = valueString.format({"playerValue" = playerValue, "enemyValue" = enemyValue, "whoBusted" = whoBustedString})

		await okButton.button_down

		#trigger resolution effects
		await winner.playArea.triggerAll(CardEffect.triggerType.WIN)
		await loser.playArea.triggerAll(CardEffect.triggerType.LOSE)
		if bust:
			await loser.playArea.triggerAll(CardEffect.triggerType.BUST)
		
		#Determine attack and defence
		var damageCounter = winner.playArea.get_children().filter(func(c): return c is ContainerCounter and c.countSubject == ContainerCounter.countWhat.ATTACK)[0]
		var damage = (damageCounter.count + winner.bonusAttack.amount) * winner.multiplierAttack.amount
		var shieldCounter = loser.playArea.get_children().filter(func(c): return c is ContainerCounter and c.countSubject == ContainerCounter.countWhat.DEFENCE)[0]
		var shields = (shieldCounter.count + loser.bonusDefence.amount) * loser.multiplierDefence.amount

		var dealtDamage = max(0, damage - shields)

		loser.hp.amount -= dealtDamage

		#Display a message about the outcome
		var winnerString = "You have {attackAmount} attack, they defend with {shieldAmount} defence. Total of {dealtDamage} is dealt. Enemy now at {newHP}."
		if winner != player:
			winnerString = "They have {attackAmount} attack, you defend with {shieldAmount} defence. Total  of {dealtDamage} is dealt. You're now at {newHP}"

		message = winnerString.format({"attackAmount" = damage, "shieldAmount" = shields, "dealtDamage" =  dealtDamage, "newHP" =  loser.hp.amount})


	else:
		message = "It's a draw {playerValue} vs. {enemyValue}, no damage dealt".format({"playerValue" = playerValue, "enemyValue" = enemyValue})

	await okButton.button_down

	await player.playArea.triggerAll(CardEffect.triggerType.END_ROUND)
	await enemy.playArea.triggerAll(CardEffect.triggerType.END_ROUND)

	enemy.playArea.disposeAll()
	player.playArea.disposeAll()

	okButton.disabled = false

	#See if another round is needed
	if player.hp.amount > 0 and enemy.hp.amount > 0:
		message = "Ready for another round?"
		await okButton.button_down
		roundLoop()

	elif player.hp.amount <= 0:
		message = "YOU LOSE :("

	elif enemy.hp.amount <= 0:
		message = "YOU WIN :)"
