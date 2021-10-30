extends WAT.Test
# Ensures lever slider physical control is working correctly.


# The lever slider instance to be tested.
var lever_slider


func pre():
	lever_slider = LeverSlider.new()
	lever_slider.knob = Utility.add_child_to(
			lever_slider, RigidBody.new(), "Knob")


func test_boundary_limits_to_collision_shape():
	var shape = BoxShape.new()
	shape.extents = Vector3(5, 5, 5)
	Utility.add_child_to(lever_slider, CollisionShape.new()).shape = shape
	lever_slider.bounds_shape = "CollisionShape"
	add_child(lever_slider)
	asserts.is_equal(lever_slider.limit, shape.extents.length())


func test_value_changed():
	add_child(lever_slider)
	watch(lever_slider, "value_changed")
	lever_slider.knob.translate(Vector3(10, 0, 0))
	yield(until_signal(lever_slider, "value_changed", 0.2), YIELD)
	asserts.is_equal(int(lever_slider.value), 102, "value set correctly")
	asserts.signal_was_emitted(lever_slider, "value_changed", "signal emitted")
	unwatch(lever_slider, "value_changed")


func post():
	lever_slider.queue_free()
