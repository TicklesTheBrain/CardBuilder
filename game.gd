extends Node2D

@export var deckManagerPacked: PackedScene
@export var deckManager: DeckManager


func _ready():
	deckManager = deckManagerPacked.instantiate()
	deckManager.buildNewDeck()
