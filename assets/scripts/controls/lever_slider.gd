class_name LeverSlider
extends Spatial
# Lever slider physical control with a knob that sets a value. Value is changed
# according to the knob's local x translation.


signal value_changed(new_value)


# Current value of the slider.
var value = 0

# Control knob of the lever.
onready var knob = $Knob


func _physics_process(_delta):
	if not knob.sleeping:
		var percentage = floor(knob.get_percentage())
		if percentage != value:
			value = percentage
			emit_signal("value_changed", value)
