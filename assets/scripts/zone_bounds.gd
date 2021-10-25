class_name ZoneBounds
extends Area
# Boundary area to trap bounded physics objects so that they can't escape.


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")
	collision_layer = Global.BOUNDARY_LAYER
	collision_mask = Global.GRABBABLE_LAYER + Global.ENVIRONMENT_LAYER


func _on_body_exited(body):
	if body is BoundedBody and body.bounds == self:
		# Perform a raycast from exited body to area to get the normal
		# required for the bounce. This position returned by the raycast hit
		# will also be the rollback position for the body.
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(body.global_transform.origin, 
				global_transform.origin, [], 
				Global.BOUNDARY_LAYER, false, true)
		body.set_exit(result, body.linear_velocity)
