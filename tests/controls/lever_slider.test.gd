extends WAT.Test
# Ensures lever slider physical control is working correctly.


func test_value_changed():
	var lever_slider = LeverSlider.new()
	lever_slider.knob = Utility.add_child_to(
			lever_slider, direct.script(LeverBody).double(), "Knob")
	lever_slider.knob.limit = 25
	add_child(lever_slider)
	watch(lever_slider, "value_changed")
	lever_slider.knob.translate(Vector3(10, 0, 0))
	yield(until_signal(lever_slider, "value_changed", 0.2), YIELD)
	asserts.is_equal(int(lever_slider.value), 70, "value set correctly")
	asserts.signal_was_emitted(lever_slider, "value_changed", "signal emitted")
	unwatch(lever_slider, "value_changed")
	lever_slider.queue_free()
