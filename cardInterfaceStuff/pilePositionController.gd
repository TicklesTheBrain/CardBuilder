extends CardPositionController
class_name PilePositionController

@export var pileCenter: Marker2D
@export var rotationPlusMinus: float

var rotations: Array[float] = []

func scuttleCards():
    if cards.size() < 1:
        rotations = []
        return
    
    while(rotations.size() != cards.size()):
        if cards.size() > rotations.size():
            rotations.push_back(getNewRotation())
        if cards.size() < rotations.size():
            rotations.pop_back()
    
    var tween = get_tree().create_tween().set_parallel()
    for i in range(cards.size()):
        var card = cards[i]
        var rotation = rotations[i]
        tween.tween_property(card, "position", pileCenter.position, cardMoveTime)
        tween.tween_property(card, "rotation_degrees", rotation, cardMoveTime)

func getNewRotation():
    return randf_range(-rotationPlusMinus, rotationPlusMinus)