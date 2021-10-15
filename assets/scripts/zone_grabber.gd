class_name ZoneGrabber
extends Area
# Area which highlights stuff closest to its center.


signal highlight_cleared


# Number of PhysicsBody in the area.
var count = 0
# The currently highlighted body, can be null.
var highlighted = null

# Dictionary of MeshInstances and their outline generated. It only highlights 
# one body but it can have many MeshInstances, so an outline is generated for
# each one and stored here.
#
# Key/value format: {MeshInstance (original): MeshInstance (outline)}
var outlines = {}


func _ready():
	var _enter = connect("body_entered", self, "_on_body_entered")
	var _exit = connect("body_exited", self, "_on_body_exited")


func _physics_process(_delta):
	if count > 0:
		var grabbables = get_overlapping_bodies()
		if count == 1 and grabbables[0] != highlighted:
			highlight(grabbables[0])
		else:
			highlight(get_closest(grabbables))


func _on_body_entered(_body):
	count += 1


func _on_body_exited(body):
	count -= 1
	if not count or body == highlighted:
		clear()


# Recursively create outline mesh for any MeshInstance child node.
func _outline(node):
	for child in node.get_children():
		if child is MeshInstance:
			var outline = MeshInstance.new()
			outline.mesh = child.mesh.create_outline(0.1)
			outlines[child] = outline
		_outline(child)


# Clears all highlighted objects.
func clear():
	for outline in outlines:
		var delete = outlines.get(outline)
		# It's possible that it has already been deleted by other means.
		if is_instance_valid(delete):
			delete.queue_free()
	outlines.clear()
	highlighted = null
	emit_signal("highlight_cleared")


# Generates the outline MeshInstances.
func generate():
	for key in outlines:
		key.add_child(outlines.get(key))


# Returns the closest body inside the area from the given position.
func get_closest(bodies = get_overlapping_bodies(),
		position = global_transform.origin):
	var closest = null
	var distance = INF
	
	for body in bodies:
		var current = body.global_transform.origin.distance_to(position)
		if current < distance:
			closest = body
			distance = current
	
	return closest


# Highlights the given object.
func highlight(body):
	if body:
		clear()
		_outline(body)
		generate()
		highlighted = body
