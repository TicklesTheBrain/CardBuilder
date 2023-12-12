extends Resource
class_name GameStateContext

enum ActorType {PLAYER, ENEMY, ACTIVE, PASSIVE, OWNER, OPPONENT}

var player: Actor
var enemy: Actor
var activeActor: Actor
var passiveActor: Actor
var persistentPlayer: PlayerStuff

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
        ActorType.OWNER:
            return actingCard.getOwner()
        ActorType.OPPONENT:
            if actingCard.getOwner() != player:
                return player
            else:
                return enemy


    return null

