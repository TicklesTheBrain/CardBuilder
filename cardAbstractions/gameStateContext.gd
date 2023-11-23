extends Resource
class_name GameStateContext

enum ActorType {PLAYER, ENEMY, ACTIVE, PASSIVE}

var player: Actor
var enemy: Actor
var activeActor: Actor
var passiveActor: Actor

var actingCard: CardData
var subjectCard: CardData
var modifiableValue: Variant

func getActorFromType(type: ActorType) -> Actor:
    match type:
        ActorType.PLAYER:
            return player
        ActorType.ENEMY:
            return enemy
        ActorType.ACTIVE:
            return activeActor
        ActorType.PASSIVE:
            return passiveActor

    return null

