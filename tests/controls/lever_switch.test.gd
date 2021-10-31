extends WAT.Test


var lever_switch


func pre():
	lever_switch = LeverSwitch.new()
	lever_switch.knob = Utility.add_child_to(
			lever_switch, direct.script(LeverBody).double(), "Knob")
	lever_switch.hinge = Utility.add_child_to(lever_switch, HingeJoint.new())
	lever_switch.hinge_enabled = false
	lever_switch.hinge_velocity = 5
	lever_switch.indicators = {}
	lever_switch.states = 2


func test_indicate():
	var powered = Utility.add_child_to(lever_switch, MockIndicator.new(), "P")
	var unpowered = Utility.add_child_to(lever_switch, MockIndicator.new(), "U")
	var unpowered_extra = Utility.add_child_to(
			lever_switch, MockIndicator.new(), "UX")
	lever_switch.indicators = {
		"a": ["U"],
		"b": ["P"],
		"z": ["UX"]
	}
	lever_switch.indicate("b")
	asserts.is_true(powered.is_on, "powered indicator turned on")
	asserts.is_true(unpowered.is_off and unpowered_extra.is_off, "others off")


func test_on_options_changed():
	lever_switch.option_section = "test_section"
	lever_switch.option_key = "test_key"
	lever_switch._on_option_changed("test_section", "test_key", -1)
	asserts.is_false(lever_switch.knob.sleeping, "knob is awakened")
	asserts.is_false(lever_switch.is_active, "switch becomes inactive")
	asserts.is_true(lever_switch.hinge.get_flag(HingeJoint.FLAG_ENABLE_MOTOR),
			"hinge joint motor is enabled")
	asserts.is_less_than(lever_switch.hinge.get_param(
			HingeJoint.PARAM_MOTOR_TARGET_VELOCITY), 0, "velocity is negative")


func test_on_ticked_activate():
	parameters([["current", "active"], [1, true], [0, false]])
	lever_switch.current = p["current"]
	lever_switch.is_active = p["active"]
	watch(lever_switch, "state_changed")
	lever_switch._on_ticked(0)
	asserts.is_true(lever_switch.knob.sleeping, "%s: lever is sleeping" % p)
	asserts.is_true(lever_switch.is_active, "%s: switch is active" % p)
	asserts.signal_was_emitted(lever_switch, 
			"state_changed", "%s: signal emitted" % p)
	unwatch(lever_switch, "state_changed")


func test_on_ticked_dormant():
	lever_switch.current = 1
	lever_switch.is_active = false
	watch(lever_switch, "state_changed")
	lever_switch._on_ticked(0)
	asserts.is_false(lever_switch.knob.sleeping, "lever is not sleeping")
	asserts.is_false(lever_switch.is_active, "switch is still inactive")
	asserts.signal_was_not_emitted(lever_switch, "state_changed", "no signal")
	unwatch(lever_switch, "state_changed")


func post():
	lever_switch.queue_free()


# Mock class for Indicator since it cannot be doubled due to being a virtual
# class (GeometryInstance cannot be doubled).
class MockIndicator extends Spatial:
	var is_on = false
	var is_off = false
	
	func on(_code):
		is_on = true
	
	func off():
		is_off = true
