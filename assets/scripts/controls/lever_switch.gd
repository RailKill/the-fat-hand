class_name LeverSwitch
extends Spatial
# Physically operable lever switch which emits a signal on state change.


signal state_changed(state)


# Current state of the lever switch.
var current = 0

# Left arrow of the switch.
onready var arrow_left = $StaticBody/Base/LeftClick
# Middle arrow of the switch.
onready var arrow_middle = $StaticBody/Base/MidClick
# Right arrow of the switch.
onready var arrow_right = $StaticBody/Base/RightClick
# Audio player node.
onready var audio_player = $AudioStreamPlayer3D
# Left indicator of the switch.
onready var bumper_left = $LeftBumper
# Right indicator of the switch.
onready var bumper_right = $RightBumper
# List of indicators controlled by the switch.
onready var indicators = [arrow_left, arrow_middle, arrow_right, 
		bumper_left, bumper_right]
# Control knob of the lever.
onready var knob = $Knob
# Number of states this switch can handle.
onready var states = knob.get_state_count()


# Lights up the correct indicator when lever ticks.
func _on_ticked(state):
	if current != state:
		current = state
		if current == 0:
			indicate([arrow_left, bumper_left])
		elif current == states - 1:
			indicate([arrow_right, bumper_right])
		else:
			indicate([arrow_middle])
		audio_player.play()
		emit_signal("state_changed", current)


# Applies bright color to the given list of turn_on indicators, while the
# remaining indicators will be turned off.
func indicate(turn_on):
	var turn_off = indicators.duplicate()
	for powered in turn_on:
		turn_off.erase(powered)
		powered.on(0)
	for unpowered in turn_off:
		unpowered.off()
