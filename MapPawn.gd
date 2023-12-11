extends TextureRect
class_name MapPawn

var prevPosition: Vector2 = Vector2()
var dragged: bool = false
var mouseOffset: Vector2 = Vector2()
var lines: Array[Vector2] = []
var mouseIn: bool = false
var rayCasts = []
@export var bakeDistance: float

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		onClickMapPawn()
	if event is InputEventMouseButton and event.is_released():
		onReleaseMapPawn()

func onClickMapPawn():
	if mouseIn:
		InputLord.mapPawnClicked.emit(self)

func onReleaseMapPawn():
	if dragged:
		InputLord.mapPawnDragReleased.emit(self)

func startDrag():
	prevPosition = position
	dragged = true
	mouseOffset = get_viewport().get_mouse_position() - position

func stopDrag():
	dragged = false

func _process(_delta):
	if dragged:
		position = get_viewport().get_mouse_position() - mouseOffset
		if (position-prevPosition).length() >= bakeDistance:
			lines.push_back(position+size/2)
			prevPosition = position

	for rcp in rayCasts:
		rcp[1].target_position = (rcp[0].position + rcp[0].size/2) - position

func maskMouseEntered():
	mouseIn = true

func maskMouseExited():
	mouseIn = false

func addNewRayCast(mapPOI: MapPOI):

	#TODO: A smarter way would be to measure distances from POIs rather than from the movable thing

	var newRayCast = RayCast2D.new()
	newRayCast.collide_with_areas = true
	newRayCast.collide_with_bodies = false
	add_child(newRayCast)
	rayCasts.push_back([mapPOI, newRayCast])
	#newRayCast.target_position = mapPOI.position + mapPOI.size/2
	newRayCast.position = size/2
	newRayCast.set_collision_mask_value(1, false)
	newRayCast.set_collision_mask_value(mapPOI.get_collision_layer(), true)

func reportDistanceToPOIs():
	#print(rayCasts.map(func(rp): return ['collider', rp[1].get_collider(),'collision point', rp[1].get_collision_point(), 'position', position, 'length', (rp[1].get_collision_point() - position).length()]))
	var distances = rayCasts.map(func(rp): return [rp[0], (rp[1].get_collision_point() - position).length()])
	for pack in distances:
		pack[0].reportCloseness(pack[1])
