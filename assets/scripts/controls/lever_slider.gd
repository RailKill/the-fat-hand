class_name LeverSlider
extends Spatial
# Lever slider physical control with a knob that sets a value. Value is changed
# according to the knob's local x translation.


signal value_changed(new_value)


# The path to the ZoneBounds' CollisionShape which keeps the lever trapped.
export(NodePath) var bounds_shape = "ControlArea/CollisionShape"
# Range limit of the lever. Overridden by bounds_shape's extents if available.
export(float, 3, 18) var limit = 10.5

# Previous local x translation of the knob control.
var previous = 0
# Current value of the slider.
var value = 0

# Control knob of the lever.
onready var knob = $Knob


func _ready():
	var boundary = get_node_or_null(bounds_shape)
	if boundary and boundary.shape is BoxShape:
		limit = boundary.shape.extents.length()


func _physics_process(_delta):
	if not knob.sleeping and floor(knob.translation.x) != previous:
		var adjusted = limit - 1
		var positivize = knob.translation.x + adjusted
		value = positivize / (adjusted * 2) * 100 if positivize else 0
		previous = floor(knob.translation.x)
		emit_signal("value_changed", value)
