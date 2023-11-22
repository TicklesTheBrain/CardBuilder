extends Node

@export var cardDisplayPacked: PackedScene
@export var cardGraftPacked: PackedScene
@export var defaultCardOrigin: Marker2D

signal orphanedCardDisplay(cd: CardDisplay)
signal newCardDisplayRequested(card: CardData)

func _ready():
    newCardDisplayRequested.connect(spawnNewCardDisplay)
    orphanedCardDisplay.connect(reparentCardDisplay)

func spawnNewCardDisplay(card: CardData):

    var newCardDisplay
    if card.graft:
        newCardDisplay = cardGraftPacked.instantiate() as CardGraftDisplay
    else:
        newCardDisplay = cardDisplayPacked.instantiate() as CardDisplay
    
    newCardDisplay.setupCardDisplay(card)
    add_child(newCardDisplay)
    if card.prevContainer and card.prevContainer.originMarker:
        newCardDisplay.position = card.prevContainer.originMarker.position
    else:
        newCardDisplay.position = defaultCardOrigin.position
    newCardDisplay.add_to_group("cd")

func reparentCardDisplay(cd: CardDisplay):
    cd.get_parent().remove_child(cd)
    add_child(cd)
