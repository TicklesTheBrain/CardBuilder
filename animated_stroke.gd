extends Node2D
class_name MultilineDrawer

@export var lines: Array[Node2D]
@export var lineDrawer: PackedScene
@export var renderTarget: TextureRect

var activeDrawer: LineDrawer
var activeRenderTarget: TextureRect

func _ready():

	await get_tree().create_timer(0.1).timeout

	activeRenderTarget = renderTarget

	for line in lines:

		if not line is Path2D and not line is Line2D:
			continue

		print('starting new line')

		var newDrawer = lineDrawer.instantiate()
		add_child(newDrawer)
		await get_tree().create_timer(0.15).timeout
		activeDrawer = newDrawer

		if line is Path2D:
			newDrawer.drawPath(line)
		elif line is Line2D:
			newDrawer.drawLine(line)

		await activeDrawer.finished
		
		activeDrawer.queue_free()
		activeRenderTarget = activeRenderTarget.duplicate()
		add_child(activeRenderTarget)
		activeRenderTarget.texture = null

	activeDrawer = null
	
func _process(_delta):
	await RenderingServer.frame_post_draw
	if activeDrawer != null:
		activeRenderTarget.texture = ImageTexture.create_from_image(activeDrawer.get_texture().get_image())
		
