extends RigidBody
# Lever knob's physics handler.


# Local x translation that determines the limit for the lever value.
export(float) var limit = 3.35
# Maximum local x position drift from starting position.
export(float) var max_drift = 4
# Maximum z rotation (in radians) range which the lever can rotate.
export(float) var max_range = 1
# List of rounded integer values where the lever should stop (excluding limit).
export(Array, int) var ticks = [0]

# Starting global position of the lever.
onready var original = global_transform
# Global forward direction of the lever.
onready var front = original.origin.direction_to(to_global(Vector3.FORWARD))
# Global right direction of the lever.
onready var right = original.origin.direction_to(to_global(Vector3.RIGHT))
# Global up direction of the lever.
onready var up = original.origin.direction_to(to_global(Vector3.UP))


func _integrate_forces(state):
	# Lock local axes.
	rotation.x = 0
	rotation.y = 0
	translation.z = 0
	
	var is_being_corrected = false
	# Correct vertical position if sinking below ground (over-extension).
	if translation.y < 0:
		state.transform.origin += up
		is_being_corrected = true
	# Correct horizontal position (detachment).
	if max_drift > 0 and abs(translation.x) > max_drift:
		state.transform.origin += -sign(translation.x) * right
		is_being_corrected = true
	# Correct z rotation (over-rotation).
	if rotation.z > max_range or rotation.z < -max_range:
		state.transform.basis = original.basis.rotated(
				front, -sign(rotation.z) * max_range)
		is_being_corrected = true
	
	# Determine if this body should be sleeping.
	if not is_being_corrected and (is_limit_passed() or is_on_tick()):
		sleeping = true


# Checks if the value limit was passed.
func is_limit_passed():
	return abs(translation.x) > limit


# Checks if the lever position is on a tick.
func is_on_tick():
	for tick in ticks:
		if round(translation.x) == tick:
			return true
	return false
