extends Resource
class_name CardType

enum Types {S, D, T, Q}
@export var type: Types

func getStringType():
    return Types.keys()[type]