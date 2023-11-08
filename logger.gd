extends Node

@export var printLevel: int = 5

func log(StuffToPrint: Array[Variant], level):
    if level >= printLevel:
        print(StuffToPrint)