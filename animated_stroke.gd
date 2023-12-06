extends Node2D
class_name MultilineDrawer

@export var lines: Array[Line2D]
#@export var lineDrawer: PackedScene
@export var renderTarget: TextureRect
@export var drawer: LineDrawer

#var activeDrawer: LineDrawer
var activeRenderTarget: TextureRect
var drawing = true

func _ready():

	activeRenderTarget = renderTarget

	for line in lines:
		#var newDrawer = lineDrawer.instantiate()
		#add_child(newDrawer)
		#newDrawer.drawLine(line)
		drawer.drawLine(line)
		
		#activeDrawer = newDrawer
		#await activeDrawer.finished
		await drawer.finished
		#activeDrawer.queue_free()
		activeRenderTarget = activeRenderTarget.duplicate()
		add_child(activeRenderTarget)
		#activeRenderTarget.texture = null

	#activeDrawer = null
	drawing = false

func _process(_delta):
	if drawing:
		await RenderingServer.frame_post_draw
		print('assigning new texture')
		#activeRenderTarget.texture = ImageTexture.create_from_image(drawer.get_texture().get_image())
		activeRenderTarget.texture = drawer.get_texture()

