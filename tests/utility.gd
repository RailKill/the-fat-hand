class_name Utility
# Utility methods strictly for test case usage only.


# Adds a given child to the parent node and set given name. If name is empty,
# it will default to the class name. Returns the given child node back.
static func add_child_to(parent, child, name = ""):
	if not name.empty():
		child.name = name
	parent.add_child(child, name.empty())
	return child


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


# Test helper to simulate an input being pressed or not.
static func simulate_action(action, pressed=true):
	var a = InputEventAction.new()
	a.action = action
	a.pressed = pressed
	Input.parse_input_event(a)
