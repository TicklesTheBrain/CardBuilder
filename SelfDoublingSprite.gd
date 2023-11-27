extends Sprite2D
class_name SelfDoublingSprite

@export var duplicateOffset: Vector2

func doubleWithOffset():
    var double = duplicate()
    get_parent().add_child(double)
    double.position += duplicateOffset
    return double