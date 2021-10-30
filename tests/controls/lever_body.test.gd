extends WAT.Test


var lever_body


func pre():
	lever_body = LeverBody.new()


func test_integrate_forces():
	var state = MockPhysicsState.new()
	lever_body.translation = Vector3.ONE * -10
	lever_body.limit = 6
	lever_body.max_drift = 8
	lever_body.max_range = 0.7
	add_child(lever_body)
	lever_body.rotation = Vector3.ONE
	watch(lever_body, "ticked")
	lever_body._integrate_forces(state)
	
	asserts.is_equal(lever_body.rotation.x, 0, "rotation x is locked to 0")
	asserts.is_equal(lever_body.rotation.y, 0, "rotation y is locked to 0")
	asserts.is_equal(lever_body.translation.z, 0, "translation z is set to 0")
	asserts.is_equal(state.transform.origin.y, 1, "state position y corrected")
	asserts.is_equal(state.transform.origin.x, 1, "state position x corrected")
	asserts.is_true(is_equal_approx(state.transform.basis.get_euler().z, 0.7), 
			"state basis z corrected")
	asserts.signal_was_not_emitted(lever_body, "ticked", 
			"no signal during correction")
	
	lever_body.translation = Vector3(6.1, 0, 0)
	lever_body.rotation = Vector3.ZERO
	lever_body._integrate_forces(state)
	asserts.signal_was_emitted(lever_body, "ticked", 
			"signal emitted upon x limit reached")
	unwatch(lever_body, "ticked")


func test_get_percentage():
	lever_body.limit = 10
	lever_body.translation.x = 7
	asserts.is_equal(lever_body.get_percentage(), 85)


func test_get_state():
	lever_body.limit = 10
	lever_body.ticks = [8, -4, 2]
	lever_body.translation.x = 7
	asserts.is_equal(lever_body.get_state(), 3)


func test_get_state_count():
	lever_body.ticks = [1, 2, 3, 4, 5]
	asserts.is_equal(lever_body.get_state_count(), 7)


func test_gravity_scale_is_zero_when_ready():
	add_child(lever_body)
	asserts.is_equal(lever_body.gravity_scale, 0)


func test_is_limit_passed():
	lever_body.limit = 9001
	lever_body.translation.x = 9002
	asserts.is_true(lever_body.is_limit_passed())


func test_is_on_tick():
	lever_body.ticks = [200, 1337, 1500]
	lever_body.translation.x = 1336.5
	asserts.is_true(lever_body.is_on_tick())


func post():
	lever_body.queue_free()


# Barebones mock of physics state for testing.
class MockPhysicsState extends Object:
	var transform = Transform.IDENTITY
