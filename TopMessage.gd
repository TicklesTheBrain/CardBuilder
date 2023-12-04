extends Node2D

@export var text: Label
@export var animation: AnimationPlayer

var showing: bool = false
signal messageHidden()

func _ready():
	Events.newTopMessageRequested.connect(showMessage)
	Events.hideTopMessages.connect(hideMessage)

func showMessage(newMessage: String):
	print('show message triggered')
	if animation.is_playing() or showing:
		hideMessage()
		await messageHidden
	
	text.text = newMessage.to_upper()
	animation.play("show")
	showing = true

func hideMessage():
	print("hide top message triggered")

	if animation.is_playing():
		var animationName = animation.current_animation
		match animationName:
			"hide":
				return
			'show':
				await animation.animation_finished
	
	animation.play("hide")
	await animation.animation_finished
	showing = false
	messageHidden.emit()
