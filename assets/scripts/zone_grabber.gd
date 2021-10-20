class_name ZoneGrabber
extends Area
# Area which highlights stuff closest to its center.


signal grab_applied(rotation_y)
signal grab_released(body)
signal highlight_cleared


# Number of PhysicsBody in the area.
var count = 0
# The currently highlighted body, can be null.
var highlighted = null
# Continues checking for objects to highlight if true.
var is_active = true
# If true, the highlighted body will be under the zone's control.
var is_grabbing = false
# Dictionary containing the original MeshInstance as the key, and the
# generated outline MeshInstance as its value.
var outlines = {}

# AudioStreamPlayer3D for grab audio.
onready var audio_grab = get_node_or_null("AudioGrab")
# AudioStreamPlayer3D for release audio.
onready var audio_release = get_node_or_null("AudioRelease")


func _ready():
	var _enter = connect("body_entered", self, "_on_body_entered")
	var _exit = connect("body_exited", self, "_on_body_exited")


func _input(event):
	if is_active:
		if event.is_action_pressed("grab") and highlighted and not is_grabbing:
			grab()
		elif event.is_action_released("grab") and is_grabbing:
			release()


func _physics_process(_delta):
	if is_active and count > 0:
		if is_grabbing and highlighted:
			highlighted.global_transform.origin = global_transform.origin
		else:
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


# Apply grab to highlighted body.
func grab():
	is_grabbing = true
	highlighted.set_mode(RigidBody.MODE_CHARACTER)
	highlighted.connect("tree_exiting", self, "release")
	emit_signal("grab_applied", 1.5708)
	if audio_grab:
		audio_grab.play()


# Highlights the given object.
func highlight(body):
	if body:
		clear()
		_outline(body)
		generate()
		highlighted = body


# Release grab of the highlighted body.
func release():
	is_grabbing = false
	if is_instance_valid(highlighted):
		highlighted.set_mode(RigidBody.MODE_RIGID)
		highlighted.disconnect("tree_exiting", self, "release")
		emit_signal("grab_released", highlighted)
	if audio_release:
		audio_release.play()
