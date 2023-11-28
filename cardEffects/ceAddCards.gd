extends CardEffect
class_name AddCards

@export var containerToAdd: Actor.ContainerPurposes
@export var cardsToAdd: CardTemplatePackage
@export var shuffleAfterwards: bool
@export var addPermanent: bool = false
@export var addOnTop: bool = false


func triggerSpecific(ctxt: GameStateContext):
    var actor = ctxt.getActorFromType(subjectActor)
    var container = actor.getContainerFromPurpose(containerToAdd)
    var newCards = DeckManager.makeCardArrayFromTemplate(cardsToAdd.cards)
    for card in newCards:
        container.addCard(card, addOnTop)
    if shuffleAfterwards:
        container.shuffle()

    if addPermanent:
        var deck = actor.getContainerFromPurpose(Actor.ContainerPurposes.DECK)
        deck.addNewTemplateCards(cardsToAdd.cards)

func mergeEffectSpecific(newEffect: CardEffect):
    print("merging added cards")
    cardsToAdd.cards.append_array(newEffect.cardsToAdd.cards)

