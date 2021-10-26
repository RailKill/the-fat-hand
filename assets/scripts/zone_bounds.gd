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
		var result = find_nearest_entry(body.global_transform.origin)
		body.set_exit(result, body.linear_velocity)


# Perform a raycast from exited body to area to get the normal required for the 
# bounce re-entry. This position returned by the raycast hit will also be the 
# rollback position for the body.
func find_nearest_entry(body_position):
	var space_state = get_world().direct_space_state
	var nearest_collision = null
	var nearest_distance = INF
	
	# Because the area can consist of many CollisionShapes, find the nearest
	# one to re-enter.
	for child in get_children():
		if child is CollisionShape:
			var shape_target = global_transform.origin + child.transform.origin
			var raycast = space_state.intersect_ray(body_position, 
					shape_target, [], Global.BOUNDARY_LAYER, false, true)
			if raycast:
				var distance = body_position.distance_to(raycast["position"])
				if distance < nearest_distance:
					nearest_collision = raycast
					nearest_distance = distance
	return nearest_collision
