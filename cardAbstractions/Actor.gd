extends Node
class_name Actor

@export var actorName: String

@export_group("Game Resources")
@export var energy: GameResource  
@export var cardsPerTurn: GameResource
@export var bonusAttack: GameResource
@export var bonusDefence: GameResource
@export var multiplierAttack: GameResource
@export var multiplierDefence: GameResource
@export var hp: GameResource
@export var bustValue: GameResource

@export_group("Containers")
@export var hand: CardContainer
@export var discard: CardContainer
@export var playArea: CardContainer
@export var deck: DeckManager
@export var items: ItemContainer

enum ContainerPurposes {DECK, HAND, PLAY_AREA, DISCARD}
enum GameResources {ENERGY, CARDS_PER_TURN, BONUS_ATTACK, BONUS_DEFENCE, MULTIPLIER_ATTACK, MULTIPLIER_DEFENCE, HP, BUST_VALUE}

var gameResources: Dictionary:
	get:
		return {
			"energy" = energy,
			"cardsPerTurn" = cardsPerTurn,
			"bonusAttack" = bonusAttack,
			"bonusDefence" = bonusDefence,
			"multiplierAttack" = multiplierAttack,
			"multiplierDefence" = multiplierDefence,
			"hp" = hp
		}

var containers: Dictionary:
	get:
		return {
			"hand" = hand,
			"discard" = discard,
			"playArea" = playArea,
			"deck" = deck
		}

func _ready():
	Events.startMatch.connect(triggerStartMatch)
	deck.populateContainerFromTemplate()
	deck.shuffle()

func triggerStartMatch():
	deck.triggerAll(GameEffect.triggerType.START_MATCH)

func getContainerFromPurpose(purpose: ContainerPurposes) -> CardContainer:
	match purpose:
		ContainerPurposes.PLAY_AREA:
			return playArea
		ContainerPurposes.HAND:
			return hand
		ContainerPurposes.DISCARD:
			return discard
		ContainerPurposes.DECK:
			return deck
	return null

func getResourceFromEnum(enumOfResource: GameResources) -> GameResource:
	match enumOfResource:
		GameResources.ENERGY:
			return energy
		GameResources.CARDS_PER_TURN:
			return cardsPerTurn
		GameResources.BONUS_ATTACK:
			return bonusAttack
		GameResources.BONUS_DEFENCE:
			return bonusDefence
		GameResources.MULTIPLIER_ATTACK:
			return multiplierAttack
		GameResources.MULTIPLIER_DEFENCE:
			return multiplierDefence
		GameResources.HP:
			return hp
		GameResources.BUST_VALUE:
			return bustValue
	return null

func resetResources(newTurnReset: bool = false):
	for res in gameResources.values():
		if newTurnReset:
			if res.resetAtNewTurn:
				res.reset()
		else:
			res.reset()

func checkIsBusted():
	return playArea.getTotalValue() > bustValue.amount

