extends Button
class_name ConfirmationButton


func _ready():
    pressed.connect(announceConfirmPressed)
    Events.confirmButtonDisable.connect(buttonDisable)
    Events.confirmButtonEnable.connect(buttonEnable)

func announceConfirmPressed():
    Events.confirmButtonPressed.emit()

func buttonDisable():
    visible = false

func buttonEnable():
    visible = true