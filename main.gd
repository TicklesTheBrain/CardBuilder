extends Node2D
class_name Main

@export var structure: Array[StructureStep] = []
@export var player: PlayerStuff

@export var gamePacked: PackedScene
@export var textScenePacked: PackedScene

func _ready():
    for step in structure:

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