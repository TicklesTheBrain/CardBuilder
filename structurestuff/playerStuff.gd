extends Resource
class_name PlayerStuff

@export var playerDeckTemplate: CardTemplatePackage
@export var items: Array[Item] = []
@export var playerHP: int
@export var playerPicId: int

func addNewTemplateCards(newCards: Array[EmptyCardData]):
	playerDeckTemplate.cards.append_array(newCards)