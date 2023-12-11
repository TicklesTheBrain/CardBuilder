extends Node2D
class_name MapScene

@export var movablePawn: MapPawn
@export var drawer: MultilineDrawer
@export var pois: Array[MapPOI] = []

func _input(event):
	if event.is_action_pressed("endTravel"):
		drawTravelLine()      

func setupMap():
	var layerID = 2
	for poi in pois:
		poi.pawnEntered.connect(choiceIsMade.bind(poi))
		poi.setCollisionLayer(layerID)
		movablePawn.addNewRayCast(poi)
		layerID += 1

func _ready():
	setupMap()

func _process(_delta):
	movablePawn.reportDistanceToPOIs()

func choiceIsMade(whatPOI: MapPOI):
	print('choice is made ', whatPOI)
	drawTravelLine()

func drawTravelLine():
	print('end travel triggered')
	var newLine = Line2D.new()
	for vec in movablePawn.lines:
		newLine.add_point(vec)
	add_child(newLine)
	newLine.visible = false
	drawer.lines.push_back(newLine)
	drawer.startDraw()
		
