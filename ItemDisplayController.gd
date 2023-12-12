extends GridContainer
class_name ItemDisplayController

@export var columnLength: int
@export var itemDisplayPacked: PackedScene
@export var logicalItemContainer: ItemContainer

func _child_update(_node: Node, childCountModify: int = 0):
    var childCount = get_children().size() + childCountModify
    var columnCount = floor(childCount / columnLength) + (1 if childCount % columnLength > 0 else 0)
    columns = max(columnCount,1)
    print('child update triggered, childcount ', childCount, ' column length ', columnLength, ' columns ', columns, ' columncount', columnCount )

func _ready():
    logicalItemContainer.itemAdded.connect(newItemDisplay)
    logicalItemContainer.itemRemoved.connect(removeItemDisplay)

func newItemDisplay(item: Item):
    var newDisplay = itemDisplayPacked.instantiate() as ItemDisplay
    newDisplay.setup(item)
    add_child(newDisplay)
    newDisplay.add_to_group("id")

func removeItemDisplay(item: Item):
    for i in get_children():
        if i.item == item:
            i.queue_free()