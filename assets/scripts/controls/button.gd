class_name ButtonPressure
extends RigidBody
# Pressure button that can be affected by any physics body.


signal on
signal off


# The point which the button actuates and triggers the on state.
export(float) var actuation_depth = 1.0
# How far can the button be pushed before bottoming out.
export(float) var bottom_depth = 1.2
# Contact weight required to bottom out.
export(float) var bottom_weight = Global.MAX_WEIGHT
# If true, the button will stay on until being triggered again.
export(bool) var is_toggle = false
# Determines how fast the button returns to its original position.
# For spring strength, change the mass instead.
export(float, 75, 100) var velocity = 80.0

# Dictionary of contact bodies and their weights.
var contact_weights = {}
# The sum of values for contact_weights, stored here to avoid recalculations.
var sum_of_weights = 0
# Current state of the button.
var is_on = false

# Button pressed audio player.
onready var audio_click = $AudioClick


func _integrate_forces(state):
	# Button only deals with up translation, no side-to-side movements.
	translation *= Vector3.UP
	# Check button actuation and update depth appropriately if bottomed out.
	translation.y = actuate(get_contact_depth(translation.y))
	# Update physical state transform.
	state.transform.origin = to_global(translation)
	apply_spring(state)


# Update contact weight when a body is in vicinity, assuming that gravity is
# not dynamic/changing during runtime.
func _on_contact_entered(body):
	var force = body.get_weight() if body.has_method("get_weight") \
			else Global.MAX_WEIGHT
	var down = -global_transform.origin.direction_to(to_global(Vector3.UP))
	contact_weights[body] = (down * ProjectSettings.get_setting(
			"physics/3d/default_gravity_vector") * force).length()
	sum_of_weights += contact_weights[body]


# Update sum of weights when a body exits.
func _on_contact_exited(body):
	sum_of_weights -= contact_weights.get(body, 0)
	contact_weights.erase(body)


# Trigger "on" state if reached actuation_depth and return the limited depth.
func actuate(depth):
	if depth < -actuation_depth and not is_on:
		audio_click.play()
		is_on = true
		emit_signal("on")
	
	return min(0, max(depth, -bottom_depth))


# Spring the button back to y-translation 0.
func apply_spring(state):
	var up = state.transform.origin.direction_to(to_global(Vector3.UP))
	state.linear_velocity = translation.y / -bottom_depth * up * velocity
	
	# Emit off state if sprung back to within half of actuation_depth.
	if translation.y > -actuation_depth / 2 and is_on:
		is_on = false
		emit_signal("off")


# Returns the depth of the button based on contact weight in comparison to the
# current depth influenced by physical objects, whichever deeper.
func get_contact_depth(physics_depth):
	return min(sum_of_weights / bottom_weight * -bottom_depth, physics_depth)
