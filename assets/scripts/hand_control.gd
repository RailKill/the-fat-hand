extends Spatial


# Maximum radial reach of the hand.
export var max_radius = 5
# Speed in which the hand can spin.
export var sensitivity = 0.05


func _input(event):
	if event is InputEventMouseMotion:
		var side = translation.x + event.relative.x * sensitivity
		var straight = translation.z + event.relative.y * sensitivity
		translation.x = clamp(side, -max_radius, max_radius)
		translation.z = clamp(straight, -max_radius, max_radius)

		# Fix hand yaw based on hand control location.
		rotation_degrees.x = rad2deg(atan2(translation.x, -translation.z))
