extends WAT.Test


var button


func pre():
	button = ButtonPressure.new()
	button.actuation_depth = 10
	button.bottom_depth = 50
	Utility.add_child_to(button, AudioStreamPlayer3D.new(), "AudioClick")
	add_child(button)


func test_actuate_bottom_out():
	asserts.is_equal(button.actuate(-200), -50)


func test_actuate_emits_on_signal():
	watch(button, "on")
	asserts.is_equal(button.actuate(-10.01), -10.01, "returned actuated depth")
	asserts.is_true(button.is_on, "is_on set to true")
	asserts.signal_was_emitted(button, "on", "on signal emitted")
	unwatch(button, "on")


func test_actuate_just_missed():
	watch(button, "on")
	asserts.is_equal(button.actuate(-10), -10, "returned actuated depth")
	asserts.is_false(button.is_on, "is_on is still false")
	asserts.signal_was_not_emitted(button, "on", "on signal was not emitted")
	unwatch(button, "on")


func test_actuate_positive_limits_to_zero():
	asserts.is_equal(button.actuate(200), 0)


func test_apply_spring_sets_velocity():
	var body = RigidBody.new()
	add_child(body)
	body.translation.y = -10
	button.translation.y = -10
	button.apply_spring(body)
	asserts.is_equal(body.linear_velocity, Vector3(0, 0.2 * button.velocity, 0))
	body.queue_free()


func test_apply_spring_emits_off_signal():
	var body = RigidBody.new()
	button.translation.y = -4
	button.is_on = true
	watch(button, "off")
	button.apply_spring(body)
	asserts.signal_was_emitted(button, "off", "signal emitted")
	asserts.is_false(button.is_on, "is_on set to false")
	unwatch(button, "off")
	body.queue_free()


func test_get_contact_depth_picks_minimum():
	button.sum_of_weights = 75.0
	button.bottom_weight = 100.0
	asserts.is_equal(button.get_contact_depth(-20.0), -37.5)


func test_on_contact_entered_with_weight_gets_added_to_sum():
	button.sum_of_weights = 10
	var body = RigidBody.new()
	body.weight = 123
	button._on_contact_entered(body)
	asserts.is_equal(button.sum_of_weights, 133)
	body.queue_free()


func test_on_contact_entered_without_weight_assumes_maximum():
	button.sum_of_weights = 69.69
	var body = KinematicBody.new()
	button._on_contact_entered(body)
	asserts.is_equal(button.sum_of_weights, Global.MAX_WEIGHT + 69.69)
	body.queue_free()


func test_on_contact_exited():
	button.sum_of_weights = 200
	var body = RigidBody.new()
	button.contact_weights[body] = 50
	button._on_contact_exited(body)
	asserts.is_equal(button.sum_of_weights, 150, "weight subtracted")
	asserts.is_false(button.contact_weights.has(body), "contact removed")
	body.queue_free()


func post():
	button.queue_free()
