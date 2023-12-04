extends Node2D

@export var text: Label
@export var animation: AnimationPlayer

var showing: bool = false
signal messageHidden()

func _ready():
	Events.newTopMessageRequested.connect(showMessage)
	Events.hideTopMessages.connect(hideMessage)

func showMessage(newMessage: String):
	if animation.is_playing():
		var animationName = animation.current_animation
		match animationName:
			"hide":
				await messageHidden
			"show":
				await animation.animation_finished
				hideMessage()
				await messageHidden
	
	if showing:
		hideMessage()
		await messageHidden
	
	text.text = newMessage.to_upper()
	animation.play("show")
	showing = true

func hideMessage():
	
	animation.play("hide")
	await animation.animation_finished
	showing = false
	messageHidden.emit()
