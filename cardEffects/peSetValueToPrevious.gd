extends SelfModifier
class_name SetValueToPrevious

func triggerSpecific(ctxt: GameStateContext):
    if ctxt.hand.getAll().size() < 2:
        #THIS MEANS THIS WAS THE FIRST CARD PLAYED
        return
    
    var valueToCopy = ctxt.hand.getLast(2).getValue()
    modifier.flatChange = valueToCopy
    super(ctxt)
    print("value copy Done")
