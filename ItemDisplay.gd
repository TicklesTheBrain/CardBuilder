extends TextureRect
class_name ItemDisplay

@export var scoreLabel: Label
@export var textLabel: RichTextLabel
@export var infoRoot: Control

var item: Item

func setup(newItem: Item):
    item = newItem
    texture = item.itemTexture
    scoreLabel.text = "Score: " + str(item.value)
    textLabel.text = CardData.getEffectTextFromBucket(item.useEffects)
    
func onClick():
    InputLord.itemClicked.emit(self)

func onMouseEnterItem():
    print('item mouse enter')
    InputLord.itemMouseOver.emit(self)

func onMouseLeaveItem():
    print('item mouse leave')
    InputLord.itemMouseOverExit.emit(self)

func showInfo():
    infoRoot.visible = true

func hideInfo():
    infoRoot.visible = false

func _gui_input(event):    
    if event is InputEventMouseButton and event.is_pressed():
       onClick()
   