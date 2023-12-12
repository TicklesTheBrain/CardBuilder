extends Node2D
class_name Main

@export var structure: Array[StructureStep] = []
@export var player: PlayerStuff

@export var gamePacked: PackedScene
@export var textScenePacked: PackedScene
@export var mapScenePacked: PackedScene

var currentStructure: Array[StructureStep] = []
var activatedStep: StructureStep
var activeScene

func _ready():
	currentStructure = structure.duplicate()
	Events.nextStep.connect(receiveActivatedStep)
	processStructure()

func processStructure():

	if activatedStep != null:
		var step = activatedStep
		activatedStep = null
		await processStep(step)

	elif currentStructure.size() > 0:
		var step = currentStructure.pop_front()
		await processStep(step)

	if activatedStep != null or currentStructure.size() > 0:
		processStructure()
	else:
		print("game closing")
		get_tree().quit()

func receiveActivatedStep(step: StructureStep):
	activatedStep = step

func processStep(step: StructureStep):

	if activeScene != null:
		Transition.showTransition()
		await Transition.done
		activeScene.queue_free()

	if step is MatchStep:

		activeScene = gamePacked.instantiate() as Game
		activeScene.setupMatch(step)
		activeScene.setupPlayer(player)
		add_child(activeScene)
		activeScene.startMatch()

	elif step is StepText:

		activeScene = textScenePacked.instantiate() as TextScene
		activeScene.setup(step)
		add_child(activeScene)
		activeScene.showText()

	elif step is MapStep:

		activeScene = mapScenePacked.instantiate() as MapScene
		activeScene.setupMap(activeScene)
		add_child(activeScene)
		activeScene.start()

	if Transition.active:
		Transition.hideTransition()

	await activeScene.complete

	if step.postStepReward != null:
		var newContext = GameStateContext.new()
		newContext.persistentPlayer = player
		step.postStepReward.trigger(newContext)

	
