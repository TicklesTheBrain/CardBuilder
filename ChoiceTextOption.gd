extends Label
class_name ChoiceTextOption

@export var mouseOverColor: Color
@export var regularColor: Color

func _gui_input(event):
	# print('input event triggered', event)
	if event is InputEventMouseButton and event.is_pressed():
		Events.textChoiceClicked.emit(self)

func _on_mouse_exited():
	set("theme_override_colors/font_color", regularColor)
    


func _on_mouse_entered():
	set("theme_override_colors/font_color", mouseOverColor)
    
