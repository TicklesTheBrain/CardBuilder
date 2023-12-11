extends Label
class_name ValueTracker

@export var containerToLookupValue: CardContainer
@export var bustResource: GameResource
@export var prefixString: String
@export var middleString: String
@export var colorRegular: Color
@export var colorBusted: Color
@export var adjustableMask: CanvasItem
@export var extraMaskSpacing: Vector2 = Vector2(15,0)

func _ready():
	Events.gameStateChange.connect(updateSelf)

func updateSelf():
	var value = containerToLookupValue.getTotalValue()
	var bustAmount = bustResource.amount
	var string = "{pre}{value}{mid}{bust}".format({"pre": prefixString, "value": value, "mid": middleString, "bust": bustAmount})
	var sizeOfString = get_theme_font("font").get_string_size(string, HORIZONTAL_ALIGNMENT_LEFT, -1, get_theme_font_size("font_size"))
	adjustableMask.size = sizeOfString+extraMaskSpacing
	text = string

	if bustAmount < value:
		self_modulate = colorBusted
	else:
		self_modulate = colorRegular


