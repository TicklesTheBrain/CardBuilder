extends CollisionShape2D

func _draw():
	draw_rect(shape.get_rect(), Color.AQUA, false, 4.0)
