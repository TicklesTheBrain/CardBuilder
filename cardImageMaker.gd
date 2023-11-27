extends Node2D

@export var cardImageTemplate: PackedScene


func getCardImage(cardData: CardData, receivingFunction: Callable):

	var newTemplate = cardImageTemplate.instantiate() as CardImageTemplate
	add_child(newTemplate)
	newTemplate.setup(cardData)

	await RenderingServer.frame_post_draw
	receivingFunction.call(ImageTexture.create_from_image(newTemplate.get_texture().get_image()))
	newTemplate.queue_free()
