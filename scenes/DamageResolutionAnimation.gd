extends Node2D
class_name DamageResolutionAnimation

@export var leftSide: ResolutionParamAnimator
@export var rightSide: ResolutionParamAnimator

@export var shieldsDelay: float
@export var smashAnimTime: float
@export var rightSideAttackChip: ResourceTracker
@export var leftSideAttackChip: ResourceTracker

var attackComplete = false:
    set(new):
        if new and defenceComplete:
            attackAndShieldBothComplete.emit()
        attackComplete = new

var delayShieldComplete = false
var defenceComplete = false:
        set(new):
            if new and attackComplete:
                attackAndShieldBothComplete.emit()
            defenceComplete = new

signal shieldGo
signal done
signal attackAndShieldBothComplete

func setLeftParam(param: CardParam.ParamType):
    leftSide.paramToShow = param

func setRightParam(param: CardParam.ParamType):
    rightSide.paramToShow = param

func start():

    var sideWithAttack = leftSide if leftSide.paramToShow == CardParam.ParamType.ATTACK else rightSide
    var sideWithDefence = rightSide if rightSide.paramToShow == CardParam.ParamType.DEFENCE else leftSide

    var totalAttackAvailable = sideWithAttack.containerToQuery.getTotalAttack()
    var totalDefenceAvailable = sideWithDefence.containerToQuery.getTotalDefence()
    var anyAttackAvailable = totalAttackAvailable > 0
    var anyDefenceAvailable = totalDefenceAvailable > 0

    if anyAttackAvailable:
        sideWithAttack.start()
        await sideWithAttack.done
        markAttackComplete()
    else:
        markAttackComplete()

    if anyDefenceAvailable:
        if not attackComplete:
            startShieldDelayTimer()
            await shieldGo
        sideWithDefence.start()
        await sideWithDefence.done
        defenceComplete = true
    else:
        defenceComplete = true

    if not (attackComplete and defenceComplete):
        print('awaiting attack and shiled to both complete')
        await attackAndShieldBothComplete
        print('awaiting done')
    
    if not anyAttackAvailable:
       pass

    elif not anyDefenceAvailable:
        sideWithAttack.hit()
        await sideWithAttack.hitDone        
    
    elif totalDefenceAvailable >= totalAttackAvailable:
        sideWithAttack.smash()
        sideWithDefence.smash()
        await sideWithAttack.smashDone
        sideWithAttack.disappear()
        sideWithDefence.setNewTarget(totalDefenceAvailable - totalAttackAvailable, 0.1)
        await sideWithDefence.smashReturnDone       

    elif totalAttackAvailable > totalDefenceAvailable:
        sideWithAttack.smash()
        sideWithDefence.smash()
        await sideWithAttack.smashDone
        sideWithDefence.disappear()
        sideWithAttack.setNewTarget(totalAttackAvailable - totalDefenceAvailable, 0.1)
        await sideWithAttack.smashReturnDone
        sideWithAttack.hit()
        await sideWithAttack.hitDone

    cleanup()
    done.emit()

func cleanup():
    leftSide.disappear()
    rightSide.disappear()
    attackComplete = false
    defenceComplete = false
    delayShieldComplete = false

func markAttackComplete():
    attackComplete = true
    shieldGo.emit()

func markDelayShieldComplete():
    delayShieldComplete = true

func startShieldDelayTimer():
    await get_tree().create_timer(shieldsDelay).timeout
    shieldGo.emit()





