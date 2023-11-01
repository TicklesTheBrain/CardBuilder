extends Resource
class_name PlayEffect

enum triggerType {NONE, PLAY, DISCARD, END, DRAW}

@export var effectName: String
@export var effectText: String

func trigger(_effectContext: GameStateContext):
    print('this was a generic play effect trigger function that was not overriden. is this expected?')
    #pass

    
