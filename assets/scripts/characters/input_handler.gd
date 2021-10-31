class_name InputHandler
extends Node


# Input map to vector directionals.
const DIRECTIONS = {
	"ui_up": Vector3.FORWARD,
	"ui_down": Vector3.BACK,
	"ui_left": Vector3.LEFT,
	"ui_right": Vector3.RIGHT
}


# Returns a directional vector based on given joy horizontal and vertical axis.
# If keyboard is set to true, it will include keyboard (e.g. WASD) inputs.
static func get_vector(horizontal, vertical, keyboard = true):
	var vector = Vector3(quell(Input.get_joy_axis(0, horizontal)), 0, 
			quell(Input.get_joy_axis(0, vertical)))
	if keyboard:
		for direction in DIRECTIONS:
			if Input.is_action_pressed(direction):
				vector += DIRECTIONS[direction]
	return vector


# Similar to Input deadzones, quell the given value so that it becomes 0 if
# it is within the given range.
static func quell(value, amount = 0.1):
	return 0 if value >= -amount and value <= amount else value
