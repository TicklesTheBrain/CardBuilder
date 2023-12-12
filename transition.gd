extends CanvasLayer
@export var animation: AnimationPlayer

var active = false
signal done()

func showTransition():
    animation.play("show")
    await animation.animation_finished
    active = true
    done.emit()

func hideTransition():
    animation.play_backwards("show")
    await animation.animation_finished
    active = false
    done.emit()