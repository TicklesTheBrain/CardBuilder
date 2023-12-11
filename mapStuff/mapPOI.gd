extends TextureRect
class_name MapPOI

var collision_layer: int
@export var collisionArea: Area2D
@export var infoThreshold: float
@export var infoLines: Array[String]
@export var infoLineLabelProto: Label
var infoLinesLabels: Array[Label] = []
signal pawnEntered()

func setCollisionLayer(newLayer: int):
	collisionArea.set_collision_layer_value(1, false)
	collisionArea.set_collision_layer_value(newLayer, true)
	collision_layer = newLayer

func get_collision_layer():
	return collision_layer

func _ready():
	for infoText in infoLines:
		var newLabel = infoLineLabelProto.duplicate()
		infoLineLabelProto.get_parent().add_child(newLabel)
		newLabel.text = infoText
		infoLinesLabels.push_back(newLabel)
	
	infoLineLabelProto.queue_free()

func reportCloseness(distance: float):
	#print('closeness reported ', distance)
	for i in range(infoLinesLabels.size()):
		var distanceToShow = (1+i)*infoThreshold
		var label = infoLinesLabels[i]
		if distance <= distanceToShow:
			label.visible = true
		else:
			label.visible = false

func _on_poi_collision_area_entered(_area:Area2D):
	pawnEntered.emit()
