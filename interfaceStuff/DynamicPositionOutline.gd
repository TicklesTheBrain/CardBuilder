extends CanvasGroup
class_name DynamicPositionOutline

@export var outlines: Array[PanelContainer]
@export var positionControllerToFollow: DynamicPositionController

func _ready():
    positionControllerToFollow.cardAreaChanged.connect(switchOutline)

func switchOutline(newId: int):
    for outline in outlines:
        outline.visible = false
    
    outlines[newId].visible = true