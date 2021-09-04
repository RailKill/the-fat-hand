extends Spatial
# Controls the fat hand that is used to punch and move objects in the game.


# Maximum radial reach of the hand.
export var max_radius = 5
# Rate at which the hand power decays every frame.
export var power_decay = 10
# Speed in which the hand can spin.
export var sensitivity = 0.05

# Amount of power in the hand right now.
var power = 0

# Physics object representing the fat hand punch.
onready var punch = $Punch
# Rotary target which the hand's IK is tracking towards.
onready var target = $Target


func _input(event):
	# Move the hand control based on mouse input with a limited radius.
	if event is InputEventMouseMotion:
		var side = translation.x + event.relative.x * sensitivity
		var straight = translation.z + event.relative.y * sensitivity
		translation.x = clamp(side, -max_radius, max_radius)
		translation.z = clamp(straight, -max_radius, max_radius)
		fix_yaw()
		
		# Sets the power of the punch.
		power = Vector2(event.relative.x, event.relative.y).length()
		
		# The punch KinematicBody already follows the position of this control
		# so this move is stationary but is still needed to trigger collision.
		punch.move_and_slide(Vector3.ZERO, Vector3.UP)


func _physics_process(_delta):
	# Power decay.
	if power > 0:
		power = max(0, power - power_decay)


# Normalize the degrees as a positive float. For example, 365 degrees will be
# turned to 5 degrees because it exceeds a full circle (360) by 5.
func normalize_degrees(degrees):
	var normalized = fmod(degrees, 360)
	if normalized < 0:
		normalized += 360
	return normalized


# Given the model's y-rotation, fix the hand's IK y-rotation. Operations are
# performed in degrees.
func fix_roll(model_rotation_y):
	target.rotation_degrees.y = normalize_degrees(model_rotation_y)
	fix_yaw()


# Fix hand yaw based on hand control location.
func fix_yaw():
	# List quadrants which the player can face.
	var degree = target.rotation_degrees.y
	var facing_right = degree >= 45 and degree < 135
	var facing_front = degree >= 135 and degree < 225
	var facing_left = degree >= 225 and degree < 315
	
	# Invert x and z as needed before atan2 calculation.
	var x = translation.x if facing_front or facing_left else -translation.x
	var inversion = 1 if facing_front or facing_right else -1
	var z = -translation.z * inversion
	
	# Side angle to be added if facing either left or right.
	var side_angle
	if facing_right:
		side_angle = 90
	elif facing_left:
		side_angle = -90
	else:
		side_angle = 0
	
	# Perform the rotation fix.
	rotation_degrees.x = inversion * rad2deg(atan2(x, z)) + side_angle
