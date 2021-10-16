class_name HandController
extends Spatial
# Controls the fat hand that is used to punch and move objects in the game.


# Maximum radial reach of the hand.
export var max_radius = 5
# Rate at which the hand power decays every frame.
export var power_decay = 10
# Speed in which the hand can spin.
export var sensitivity = 0.05

# If false, do not read input events.
var is_enabled = true
# Amount of power in the hand right now.
var power = 0

# Physics object representing the fat hand punch.
onready var puncher = $Puncher
# Rotary target which the hand's IK is tracking towards.
onready var target = $Target


func _input(event):
	# Move the hand control based on mouse input with a limited radius.
	if is_enabled and event is InputEventMouseMotion:
		var side = translation.x + event.relative.x * sensitivity
		var straight = translation.z + event.relative.y * sensitivity
		translation.x = clamp(side, -max_radius, max_radius)
		translation.z = clamp(straight, -max_radius, max_radius)
		fix_yaw()
		
		# Sets the power of the punch.
		power = max(power, Vector2(event.relative.x, event.relative.y).length())
		
		# The punch KinematicBody already follows the position of this control
		# so this move is stationary but is still needed to trigger collision.
		puncher.move_and_slide(Vector3.ZERO, Vector3.UP)


func _physics_process(_delta):
	# Power decay.
	if power > 0:
		power = max(0, power - power_decay)


# Set hand to the given y rotation in radians when gripping on something.
func _on_grip_apply(rotation_y):
	target.rotation.y = rotation_y


# Reset the hand's rotation.
func _on_grip_reset(_body):
	target.rotation.y = 0


# Given the model's y-rotation in radians, fix the hand's IK y-rotation.
func fix_roll(model_rotation_y):
	rotation.y = model_rotation_y
	fix_yaw()


# Fix hand yaw based on hand control location.
func fix_yaw():
	var theta = rotation.y
	# Perform rotation of axis to get the correct (x, z) coordinates.
	var x  = translation.x * cos(theta) + -translation.z * sin(theta)
	var z  = translation.x * sin(theta) + translation.z * cos(theta)
	rotation.x = atan2(x, z)
