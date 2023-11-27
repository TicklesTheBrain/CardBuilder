extends Node2D

@export var cardImageTemplate: PackedScene


func getCardImage(type: CardType.Types, number: int, receivingFunction: Callable):

	var newTemplate = cardImageTemplate.instantiate() as CardImageTemplate
	add_child(newTemplate)
	newTemplate.setup(type, number)

	await RenderingServer.frame_post_draw
	receivingFunction.call(ImageTexture.create_from_image(newTemplate.get_texture().get_image()))
	newTemplate.queue_free()