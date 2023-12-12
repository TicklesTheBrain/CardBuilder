extends SelfModifier
class_name SetValueToPrevious

func triggerSpecific(ctxt: GameStateContext):

    var actor = ctxt.getActorFromType(subjectActor)	 
    if actor.playArea.getAll().size() < 2:
        #THIS MEANS THIS WAS THE FIRST CARD PLAYED
        return
    
    var valueToCopy = actor.playArea.getLast(2).getValue()
    modifier.flatChange = valueToCopy
    super(ctxt)
    print("value copy Done")
