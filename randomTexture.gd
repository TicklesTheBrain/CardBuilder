extends TextureRect
class_name RandomTextureSprite

@export var randomTextures: Array[Texture2D] = []

func _ready():
    texture = randomTextures.pick_random()
