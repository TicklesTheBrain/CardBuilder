extends Node
class_name ItemContainer

signal itemAdded(item: Item)
signal itemRemoved(item: Item)

@export var items: Array[Item] = []
var persistentItemArray: Array[Item]

func addNewItem(newItem: Item):
    addItem(newItem)
    if persistentItemArray != null:
        persistentItemArray.push_back(newItem.duplicate())

func removeItem(itemToRemove: Item):
    items.erase(itemToRemove)
    itemRemoved.emit(itemToRemove)
    if persistentItemArray != null:
        persistentItemArray.erase(itemToRemove)

func addItem(newItem: Item):
    items.push_back(newItem)
    itemAdded.emit(newItem)
    newItem.container = self

func setupPersistentArray(newPersistent: Array[Item]):
    for item in newPersistent:
        addItem(item.duplicate())
    persistentItemArray = newPersistent
