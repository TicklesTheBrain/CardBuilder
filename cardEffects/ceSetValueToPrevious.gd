extends SelfModifier
class_name SetValueToPrevious

func triggerSpecific(ctxt: GameStateContext):
    if ctxt.playArea.getAll().size() < 2:
        #THIS MEANS THIS WAS THE FIRST CARD PLAYED
        return
    
    var valueToCopy = ctxt.playArea.getLast(2).getValue()
    modifier.flatChange = valueToCopy
    super(ctxt)
    print("value copy Done")
