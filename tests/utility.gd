class_name Utility
# Utility methods strictly for test case usage only.


# Helper method to create an empty Spatial.
# If parent node is provided, add the Spatial as child and set given position.
static func create_spatial(parent = null, position = Vector3.ZERO):
	var spatial = Spatial.new()
	if parent:
		parent.add_child(spatial)
		spatial.global_transform.origin = position
	return spatial


# Checks if node instance is valid, then queue_free() it.
static func destroy(node):
	if is_instance_valid(node):
		node.queue_free()
