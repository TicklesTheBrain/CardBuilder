extends SubViewport
class_name LineDrawer

@export var emitter: GPUParticles2D
@export var timeFor100px: float

signal finished()

func drawLine(line: Line2D):
	emitter.emitting = true
	var points = line.points
	var startingPoint = points[0]
	points.remove_at(0)
	emitter.position = startingPoint
	moveToPoints(points)
	await finished
	emitter.emitting = false

func moveToPoints(listOfPoints: PackedVector2Array):

	var nextPoint = listOfPoints[0]
	listOfPoints.remove_at(0)
	var distance = (emitter.position - nextPoint).length()
	var travelTime = distance/100*timeFor100px

	var tween = get_tree().create_tween()
	tween.tween_property(emitter, "position", nextPoint, travelTime)
	if listOfPoints.size() > 0:
		tween.tween_callback(moveToPoints.bind(listOfPoints))
	else:
		tween.tween_callback(announceFinished)

func announceFinished():
	finished.emit()
	emitter.restart()
