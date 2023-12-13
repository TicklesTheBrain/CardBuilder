extends Node2D
class_name Game

@export_group("Debug")
@export var selfStart: bool = false
@export var selfStartStep: MatchStep
@export var selfStartPlayer: PlayerStuff

@export_group("Controller References")
@export var playAreaPositionController: DynamicPositionController
@export var enemyPlayAreaPositionController: DynamicPositionController

@export_group("UI references")
@export var messageLabel: Label
@export var drawCardButton: Button
@export var endHandButton: Button
@export var okButton: Button

@export_group("Logic references")
@export var player: Actor
@export var enemy: Actor
var activeActor: Actor
var passiveActor: Actor
var persistentPlayer: PlayerStuff

var message: String:
	set (value):
		message = value
		messageLabel.text = value

signal complete()

func startMatch():

	Events.requestContext.connect(provideContext)
	Events.startMatch.emit()
	roundLoop()

func _ready():
	
	if selfStart:
		setupMatch(selfStartStep)
		setupPlayer(selfStartPlayer)
		startMatch()

func setupMatch(structureStep: StructureStep):
	
	enemy.deck.templatePackage = structureStep.opponentDeck
	enemy.hp.baseline = structureStep.opponentHP
	enemy.bustValue.baseline = structureStep.opponentBustBaseline
	player.energy.baseline = structureStep.playerEnergyBaseline
	player.bustValue.baseline = structureStep.playerBustBaseline

func setupPlayer(newPersistentPlayer: PlayerStuff):
	player.items.setupPersistentArray(newPersistentPlayer.items)
	player.deck.templatePackage = newPersistentPlayer.playerDeckTemplate
	player.hp.baseline = newPersistentPlayer.playerHP
	persistentPlayer = newPersistentPlayer

func makeContext() -> GameStateContext:
	
	var ctxt = GameStateContext.new() as GameStateContext 
	ctxt.player = player
	ctxt.enemy = enemy
	ctxt.activeActor = activeActor
	ctxt.passiveActor = passiveActor
	ctxt.persistentPlayer = persistentPlayer
	return ctxt

func provideContext(receivingContextCallable: Callable):		
	receivingContextCallable.call(makeContext())

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
	if enemy.checkIsBusted():
		return false
	if enemy.playArea.getTotalValue() > valueToBeat:
		return false

	enemyPlayTopCard()
	return true

func enemyPlayTopCard():
	var card = enemy.deck.drawCard()
	enemy.playArea.addCard(card)

func askToShowCardDetails(cardDisplay: CardDisplay, addExitDelegate: Callable):
	cardDisplay.showDetailed()
	addExitDelegate.call(cardDisplay, cardDisplay.hideDetailed)

func askToShowItemDetails(itemDisplay: ItemDisplay, addExitDelegate: Callable):
	itemDisplay.showInfo()
	addExitDelegate.call(itemDisplay, itemDisplay.hideInfo)

func recordPersistentPlayer():
	if persistentPlayer == null:
		print ('no persistent player to record')
		return

	persistentPlayer.playerHP = player.hp.amount
	#TODO: add other stuff here

func roundLoop():
	
	## PLAYER TURN SETUP
	message = 'New round started'

	InputLord.addDragContainers(player.hand)
	InputLord.addCardMouseOverDelegate(player.hand, askToShowCardDetails)
	InputLord.addCardMouseOverDelegate(player.playArea, askToShowCardDetails)
	InputLord.addItemMouseOverDelegate(player.items, askToShowItemDetails)
	InputLord.itemsClickable = true
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
	Events.confirmButtonDisable.emit()

	await endHandButton.button_down

	## CLEANUP AT THE END OF PLAYER TURN
	playAreaPositionController.switchCardArea(1)
	enemyPlayAreaPositionController.switchCardArea(1)
	InputLord.removeDragContainers(player.hand)

	drawCardButton.disabled = true
	endHandButton.disabled = true

	var playerValue = player.playArea.getTotalValue()
	var playerBusted = player.checkIsBusted()

	Events.playerTurnEnd.emit(playerValue, playerBusted)	

	##ENEMY ACTIONS

	activeActor = enemy
	passiveActor = player

	while (enemySingleStep(playerValue)):
		await get_tree().create_timer(0.75).timeout

	Events.confirmButtonEnable.emit()

	message = "Enemy Finished playing"

	await Events.confirmButtonPressed
	
	##ROUND RESOLUTION
	var winner: Actor
	var loser: Actor
	var bust: bool

		#Determine winner/loser
	playerValue = player.playArea.getTotalValue() #Update this in case when some enemy effects might alter player value
	var enemyValue = enemy.playArea.getTotalValue()
	if player.checkIsBusted():
		winner = enemy
		loser = player
		bust = true
	elif enemy.checkIsBusted():
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

		await Events.confirmButtonPressed

		#trigger resolution effects
		await winner.playArea.triggerAll(GameEffect.triggerType.WIN)
		await loser.playArea.triggerAll(GameEffect.triggerType.LOSE)
		if bust:
			await loser.playArea.triggerAll(GameEffect.triggerType.BUST)
		
		#Determine attack and defence
		var damageCount = winner.playArea.getTotalAttack()		
		var damage = (damageCount + winner.bonusAttack.amount) * winner.multiplierAttack.amount
		var shieldCount = loser.playArea.getTotalDefence()
		var shields = (shieldCount+ loser.bonusDefence.amount) * loser.multiplierDefence.amount

		var dealtDamage = max(0, damage - shields)

		loser.hp.amount -= dealtDamage

		#Display a message about the outcome
		var winnerString = "You have {attackAmount} attack, they defend with {shieldAmount} defence. Total of {dealtDamage} is dealt. Enemy now at {newHP}."
		if winner != player:
			winnerString = "They have {attackAmount} attack, you defend with {shieldAmount} defence. Total  of {dealtDamage} is dealt. You're now at {newHP}"

		message = winnerString.format({"attackAmount" = damage, "shieldAmount" = shields, "dealtDamage" =  dealtDamage, "newHP" =  loser.hp.amount})


	else:
		message = "It's a draw {playerValue} vs. {enemyValue}, no damage dealt".format({"playerValue" = playerValue, "enemyValue" = enemyValue})

	await Events.confirmButtonPressed

	await player.playArea.triggerAll(GameEffect.triggerType.END_ROUND)
	await enemy.playArea.triggerAll(GameEffect.triggerType.END_ROUND)

	enemy.playArea.disposeAll()
	player.playArea.disposeAll()
	player.deck.shuffle()

	Events.confirmButtonEnable.emit()

	#See if another round is needed
	if player.hp.amount > 0 and enemy.hp.amount > 0:
		message = "Ready for another round?"
		await Events.confirmButtonPressed
		roundLoop()

	elif player.hp.amount <= 0:
		message = "YOU LOSE :("
		await Events.confirmButtonPressed
		complete.emit()

	elif enemy.hp.amount <= 0:
		message = "YOU WIN :)"
		await Events.confirmButtonPressed
		complete.emit()
