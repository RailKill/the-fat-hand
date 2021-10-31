class_name LeverSwitch
extends Spatial
# Physically operable lever switch which emits a signal on state change.


signal state_changed(state)


# ConfigFile section for option-saving. Leave blank if not affecting settings.
export(String) var option_section = ""
# ConfigFile key for option-saving. Leave blank if not affecting settings.
export(String) var option_key = ""
# Indicators that can light up. Direction string as key, NodePath as value.
export(Dictionary) var indicators = {
	"left": ["StaticBody/Base/LeftClick", "LeftBumper"],
	"right": ["StaticBody/Base/RightClick", "RightBumper"],
	"middle": ["StaticBody/Base/MidClick"]
}

# Current state of the lever switch.
var current: int
# When this is false, the knob is being moved by the game instead of player.
var is_active: bool

# Audio player node.
onready var audio_player = get_node_or_null("AudioLever")
# Reference to the HingeJoint node for better control.
onready var hinge = $HingeJoint
# Store original hinge value for motor enabled.
onready var hinge_enabled = hinge.get_flag(HingeJoint.FLAG_ENABLE_MOTOR)
# Store original hinge velocity for motor.
onready var hinge_velocity = hinge.get_param(
		HingeJoint.PARAM_MOTOR_TARGET_VELOCITY)
# Control knob of the lever.
onready var knob = $Knob
# Number of states this switch can handle.
onready var states = knob.get_state_count()


func _ready():
	current = int(Global.options.get_value(option_section, option_key, 0))
	_on_option_changed(option_section, option_key, current)
	if not option_section.empty() and not option_key.empty():
		# warning-ignore:return_value_discarded
		Global.connect("option_changed", self, "_on_option_changed")


# Move the lever to the given value by applying motor force until the lever's
# position matches the value.
func _on_option_changed(section, key, value):
	if option_section == section and option_key == key:
		current = value
		knob.sleeping = false
		is_active = false
		var lever_state = knob.get_state()
		hinge.set_flag(HingeJoint.FLAG_ENABLE_MOTOR, true)
		hinge.set_param(HingeJoint.PARAM_MOTOR_TARGET_VELOCITY, 
				abs(hinge_velocity) * (-1.0 if lever_state > value else 1.0))


# Lights up the correct indicator when lever ticks.
func _on_ticked(state):
	if is_active and current != state or not is_active and current == state:
		current = state
		indicate({0: "left", states - 1: "right"}.get(current, "middle"))
		knob.sleeping = true
		is_active = true
		hinge.set_flag(HingeJoint.FLAG_ENABLE_MOTOR, hinge_enabled)
		hinge.set_param(HingeJoint.PARAM_MOTOR_TARGET_VELOCITY, hinge_velocity)
		if not option_section.empty() and not option_key.empty():
			Global.set_option(option_section, option_key, state, false)
		if audio_player:
			audio_player.play()
		emit_signal("state_changed", current)


# Applies bright color to the given key of turn_on indicators, while the
# remaining indicators will be turned off.
func indicate(turn_on):
	for powered in indicators.get(turn_on, []):
		get_node(powered).on(0)
	
	for key in indicators.keys():
		if key != turn_on:
			for unpowered in indicators[key]:
				get_node(unpowered).off()
