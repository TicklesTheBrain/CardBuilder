extends Node2D
class_name Main

@export var structure: Array[StructureStep] = []
@export var player: PlayerStuff

@export var gamePacked: PackedScene
@export var textScenePacked: PackedScene
@export var mapScenePacked: PackedScene

var currentStructure: Array[StructureStep] = []
var activatedStep: StructureStep

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

func receiveActivatedStep(step: StructureStep):
	activatedStep = step

func processStep(step: StructureStep):

	if step is MatchStep:

		var newMatch = gamePacked.instantiate() as Game
		newMatch.setupMatch(step)
		newMatch.setupPlayer(player)
		add_child(newMatch)
		newMatch.startMatch()
		await newMatch.complete
		newMatch.queue_free()

	elif step is StepText:

		var newText = textScenePacked.instantiate() as TextScene
		newText.setup(step)
		add_child(newText)
		newText.showText()
		await newText.complete
		newText.queue_free()

	elif step is MapStep:

		var newMap = mapScenePacked.instantiate() as MapScene
		newMap.setupMap(step)
		add_child(newMap)
		newMap.start()
		await newMap.complete
		newMap.queue_free()
