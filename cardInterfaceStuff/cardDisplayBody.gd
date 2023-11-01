extends PanelContainer


func _gui_input(event):
	# print('input event triggered', event)
	if event is InputEventMouseButton and event.is_pressed():
		get_parent().onClick()
	if event is InputEventMouseButton and event.is_released():
		get_parent().onRelease()
