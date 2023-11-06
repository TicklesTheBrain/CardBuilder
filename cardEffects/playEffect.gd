extends Resource
class_name PlayEffect

enum triggerType {NONE, PLAY, DISCARD, END, DRAW}

@export var effectName: String
@export var staticText: String

func trigger(_effectContext: GameStateContext):
    print('this was a generic play effect trigger function that was not overriden. is this expected?')
    #pass

func getText() -> String:
    if staticText:
        return staticText
    else:
        return "this was a not overriden generic getText, something wrong?"

