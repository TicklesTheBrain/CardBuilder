extends Node


@export var doublingCutOut: SelfDoublingSprite
@export var doublingManaCoin: SelfDoublingSprite

@export var resourceToTrack: GameResource

var cutOuts = []
var manaCoins = []

func _ready():
	resourceToTrack.amountChanged.connect(showAmount)
	showAmount(resourceToTrack.amount)

func showAmount(newAmount: int):

	var rootDoublerInt = 1 if doublingCutOut.visible else 0
	var doublerVisible = 0 if doublingCutOut.visible else 1
	var difference = newAmount - (cutOuts.size() + rootDoublerInt)

	#print('show amount ', newAmount, ' difference ', difference, 'current double ', cutOuts.size())
	
	if difference == 0:
		return
	elif difference > 0:
		doublingCutOut.visible = true
		doublingManaCoin.visible = true
		for i in range(difference-doublerVisible):
			if cutOuts.size() == 0:
				cutOuts.push_back(doublingCutOut.doubleWithOffset())
			else:
				cutOuts.push_back(cutOuts[cutOuts.size()-1].doubleWithOffset())

			if manaCoins.size() == 0:
				manaCoins.push_back(doublingManaCoin.doubleWithOffset())
			else:
				manaCoins.push_back(manaCoins[manaCoins.size()-1].doubleWithOffset())
	elif difference < 0:
		for i in range(-(difference+doublerVisible)):
			if cutOuts.size() == 0: break
			cutOuts.pop_at(cutOuts.size()-1).queue_free()
			manaCoins.pop_at(manaCoins.size()-1).queue_free()
	if newAmount < 1:
		doublingCutOut.visible = false
		doublingManaCoin.visible = false
