extends Node2D
class_name MapScene

@export var movablePawn: MapPawn
@export var drawer: MultilineDrawer
@export var pois: Array[MapPOI] = []
@export var poiMarkersRoot: Node2D
var myStep: MapStep

signal finished()

func _input(event):
	if event.is_action_pressed("endTravel"):
		drawTravelLine()      

func setupMap(mapStep: MapStep):
	myStep = mapStep
	var layerID = 2
	var markerCounter = 0
	for packedPoi in mapStep.mapPoiScenes:

		var pos = poiMarkersRoot.get_child(markerCounter).position
		markerCounter +=1

		var poi = packedPoi.instantiate() as MapPOI
		add_child(poi)
		pois.push_back(poi)
		poi.position = pos
		poi.pawnEntered.connect(choiceIsMade.bind(poi))
		poi.setCollisionLayer(layerID)
		movablePawn.addNewRayCast(poi)
		layerID += 1

func _process(_delta):
	movablePawn.reportDistanceToPOIs()

func choiceIsMade(whatPOI: MapPOI):
	print('choice is made ', whatPOI)
	await drawTravelLine()

	var choiceId = pois.find(whatPOI)
	Events.nextStep.emit(myStep.resultSteps[choiceId])
	finished.emit()

func drawTravelLine():

	print('end travel triggered')
	var newLine = Line2D.new()
	for vec in movablePawn.lines:
		newLine.add_point(vec)
	add_child(newLine)
	newLine.visible = false
	drawer.lines.push_back(newLine)
	drawer.startDraw()
	await drawer.finished
		
