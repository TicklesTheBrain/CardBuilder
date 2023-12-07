extends SubViewport
class_name LineDrawer

@export var emitter: GPUParticles2D
@export var timeFor100px: float

var activeFollower: PathFollow2D

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
	await tween.finished
	if listOfPoints.size() > 0:
		moveToPoints(listOfPoints)
	else:
		finished.emit()

func drawPath(path: Path2D):

	emitter.emitting = true

	var distance = path.curve.get_baked_length()
	var travelTime = distance/100*timeFor100px

	var newFollower = PathFollow2D.new()
	path.add_child(newFollower)
	activeFollower = newFollower

	var tween = get_tree().create_tween()
	tween.tween_property(newFollower, "progress_ratio", 1.0, travelTime)
	await tween.finished

	activeFollower = null
	newFollower.queue_free()
	emitter.emitting = false
	finished.emit()

func _process(_delta):
	if activeFollower != null:
		emitter.position = activeFollower.position
		
