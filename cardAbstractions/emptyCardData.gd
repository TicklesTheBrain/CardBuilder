extends CardData
class_name EmptyCardData

@export var amount: int = 0
@export var debug: bool

func duplicateSelf() -> CardData:
    var newCard = super()
    newCard.templateCard = self
    return newCard