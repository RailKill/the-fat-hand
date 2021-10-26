class_name BoundedBody
extends RigidBody
# A movable RigidBody that must exist within a given ZoneBounds. If it is
# outside of the area, it will be moved back in via _integrate_forces().


# NodePath to the bounding play area.
export(NodePath) var bounds_path = "../PlayArea"

# ZoneBounds area in which this RigidBody must be inside of.
var bounds
# Collision point which the bounded object exited its bounded area.
# null when body is within bounds and has not exited the area.
var exit_point = null
# The recorded velocity when this body exits the area.
var exit_velocity = Vector3.ZERO


func _ready():
	bounds = get_node_or_null(bounds_path)


func _integrate_forces(state):
	if exit_point and is_instance_valid(bounds):
		state.transform.origin = conform(exit_point["position"] + \
			global_transform.origin.distance_to(exit_point["position"]) * \
			exit_point["position"].direction_to(global_transform.origin) / 2)
		state.linear_velocity = exit_velocity.bounce(exit_point["normal"])
		reset()


# Conform a given vector to axis lock.
func conform(vector):
	var conformed = vector
	if axis_lock_linear_x:
		conformed.x = global_transform.origin.x
	if axis_lock_linear_y:
		conformed.y = global_transform.origin.y
	if axis_lock_linear_z:
		conformed.z = global_transform.origin.z
	return conformed


# Resets bounding body if it is inside the bounding area.
func reset():
	if bounds.overlaps_body(self):
		exit_point = null
		exit_velocity = Vector3.ZERO


# Sets the collision point where this bounded body exits its bounded area.
func set_exit(collision, velocity = linear_velocity):
	exit_point = collision
	exit_velocity = velocity
