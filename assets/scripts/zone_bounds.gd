class_name ZoneBounds
extends Area
# Boundary area to trap bounded physics objects so that they can't escape.


# Path to player. Used to re-enter out-of-bounds bodies towards the player.
export(NodePath) var player_path = "../Player"

# If there is no player, the re-entry checks for position of collision shapes.
onready var player = get_node_or_null(player_path)


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
	var search_list = get_children()
	if player:
		search_list.append(player)
	
	# Because the area can consist of many CollisionShapes, find the nearest
	# one to re-enter.
	for node in search_list:
		var position = node.transform.origin
		var target = global_transform.origin + position if \
				is_a_parent_of(node) else position.move_toward(
				body_position.direction_to(position), 
				body_position.distance_to(position) * 2)
		
		var raycast = space_state.intersect_ray(body_position, target, [], 
				Global.BOUNDARY_LAYER, false, true)
		if raycast:
			var distance = body_position.distance_to(raycast["position"])
			if distance < nearest_distance:
				nearest_collision = raycast
				nearest_distance = distance
	return nearest_collision
