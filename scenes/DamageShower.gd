extends Node2D
class_name ResolutionParamAnimator

@export var containerToQuery: CardContainer
@export var cardNudgeVector: Vector2
@export var paramToShow: CardParam.ParamType
@export var animation: AnimationPlayer

@export var maxScale: float
@export var valueAtMaxScale: int
@export var startScale: float

@export var valueLabel: Label
@export var singleCardAnimationTime: float
@export var iconSprite: Sprite2D
@export var attackTex: Texture2D
@export var defenceTex: Texture2D
@export var disappearTime: float

signal done
signal hitDone
signal smashDone
signal smashReturnDone

var textAndScaleAnimationTime: float = 0.1

var currentValue:float = 0:
	set(newValue):
		valueLabel.text = str(newValue)
		currentValue = newValue

var targetValue:float = 0:
	set(newValue):
		var weight = targetValue/valueAtMaxScale
		var lerpedValue = lerp(startScale, maxScale, weight)
		targetScale = clamp(lerpedValue, startScale, maxScale)
		targetValue = newValue

var valueChangeCounter = 0
var targetScale = startScale

func start():
	animation.play("RESET")
	match paramToShow:
		CardParam.ParamType.ATTACK:
			iconSprite.texture = attackTex
		CardParam.ParamType.DEFENCE:
			iconSprite.texture = defenceTex
		
	visible = true
	currentValue = 0
	for card in containerToQuery.getAll():
		await addParamFromOneCard(card)

	done.emit()

func addParamFromOneCard(card: CardData):
	var additionalParamValue

	match paramToShow:
		CardParam.ParamType.ATTACK:
			additionalParamValue = card.getAttack()
		CardParam.ParamType.DEFENCE:
			additionalParamValue = card.getDefence()

	if additionalParamValue > 0:
		setNewTarget(targetValue+additionalParamValue, singleCardAnimationTime)
		#print('target scale', targetScale, ' lerpedValue ', lerpedValue, ' weight ', weight)
		var tween = get_tree().create_tween()
		var cd = CardDisplayLord.getCardDisplay(card)
		
		tween.tween_property(cd, "position", cd.position+cardNudgeVector, singleCardAnimationTime)
		await tween.finished
		tween = get_tree().create_tween()
		tween.tween_property(cd, "position", cd.position-cardNudgeVector, singleCardAnimationTime)

func _process(delta):
	if currentValue != targetValue:
		valueChangeCounter += delta
		currentValue = clamp(floor(lerp(currentValue, targetValue, valueChangeCounter/singleCardAnimationTime)), currentValue, targetValue)
		var clampedScale = clamp(lerp(scale.x, targetScale, valueChangeCounter/singleCardAnimationTime), scale.x, targetScale)
		scale = Vector2(clampedScale, clampedScale)

func setNewTarget(newTarget, time: float = textAndScaleAnimationTime):
	targetValue = float(newTarget)
	textAndScaleAnimationTime = time
	valueChangeCounter = 0

func smash():
	animation.play("smash")
	await animation.animation_finished
	smashDone.emit()
	animation.play("smashReturn")
	smashReturnDone.emit()

func hit():
	animation.play("hit")
	await animation.animation_finished
	hitDone.emit()

func disappear():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.05,0.05), disappearTime)
	await tween.finished
	visible = false