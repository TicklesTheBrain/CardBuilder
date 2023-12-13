extends Node2D
class_name ResolutionParamAnimator

@export var containerToQuery: CardContainer
@export var cardNudgeVector: Vector2
@export var paramToShow: CardParam.ParamType

@export var maxScale: float
@export var valueAtMaxScale: int
@export var startScale: float

@export var valueLabel: Label
@export var singleCardAnimationTime: float
@export var iconSprite: Sprite2D
@export var attackTex: Texture2D
@export var defenceTex: Texture2D

signal done

var currentValue:float = 0:
	set(newValue):
		valueLabel.text = str(newValue)
		currentValue = newValue
var targetValue:float = 0
var valueChangeCounter = 0
var targetScale = startScale

func start():
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
		targetValue += additionalParamValue
		var weight = targetValue/valueAtMaxScale
		var lerpedValue = lerp(startScale, maxScale, targetValue/valueAtMaxScale)
		targetScale = clamp(lerpedValue, startScale, maxScale)
		print('target scale', targetScale, ' lerpedValue ', lerpedValue, ' weight ', weight)
		valueChangeCounter = 0
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




