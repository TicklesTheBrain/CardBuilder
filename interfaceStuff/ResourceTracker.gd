extends Label
class_name ResourceTracker

@export var resourceToTrack: GameResource

func _ready():
	resourceToTrack.amountChanged.connect(showAmount)
	showAmount(resourceToTrack.amount)

func showAmount(newAmount: int):
	text = str(newAmount)