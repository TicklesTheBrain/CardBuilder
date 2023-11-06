extends Resource
class_name GameStateContext

var drawDeck: DeckManager
var playArea: CardContainer
var discard: CardContainer
var hand: CardContainer
var energyResource: GenericResource
var actingCard: CardData
var subjectCard: CardData
var modifiableValue: Variant

enum ContainerPurposes {DECK, HAND, PLAY_AREA, DISCARD}

func getContainerFromPurpose(purpose: Game.ContainerPurposes):
    match purpose:
        Game.ContainerPurposes.PLAY_AREA:
            return playArea
        Game.ContainerPurposes.HAND:
            return hand
        Game.ContainerPurposes.DISCARD:
            return discard
        Game.ContainerPurposes.DECK:
            return drawDeck