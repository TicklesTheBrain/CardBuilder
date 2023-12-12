extends GridContainer
class_name ItemDisplayController

@export var columnLength: int
@export var itemDisplayPacked: PackedScene
@export var logicalItemContainer: ItemContainer

func _child_update(_node:Node):
    var childCount = get_children().size()
    var columnCount = floor(childCount / columnLength)
    columns = columnCount

func _ready():
    logicalItemContainer.itemAdded.connect(newItemDisplay)
    logicalItemContainer.itemRemoved.connect(removeItemDisplay)

func newItemDisplay(item: Item):
    var newDisplay = itemDisplayPacked.instantiate() as ItemDisplay
    newDisplay.setup(item)
    add_child(newDisplay)

func removeItemDisplay(item: Item):
    for i in get_children():
        if i.item == item:
            i.queue_free()