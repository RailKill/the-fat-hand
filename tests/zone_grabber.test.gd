extends WAT.Test
# Test for ZoneGrabber to highlight and grab objects.


# Grabber object to be tested.
var grabber


func pre():
	grabber = ZoneGrabber.new()
	add_child(grabber)


func test_clear_highlight():
	var original = MeshInstance.new()
	var outline = MeshInstance.new()
	grabber.outlines = {original: outline}
	grabber.clear()
	yield(until_signal(grabber, "highlight_cleared", 0.2), YIELD)
	asserts.is_valid_instance(original, "original MeshInstance exists")
	asserts.is_not_valid_instance(outline, "outline MeshInstance destroyed")
	Utility.destroy(original)
	Utility.destroy(outline)


func test_generate_highlight():
	var key = Spatial.new()
	var value = Spatial.new()
	grabber.outlines = {key: value}
	grabber.generate()
	asserts.is_true(key.is_a_parent_of(value))
	Utility.destroy(key)
	Utility.destroy(value)


func test_get_closest_body():
	var first = Utility.create_spatial(self, Vector3(20, 20, 20))
	var second = Utility.create_spatial(self, Vector3(10, 10, 10)) # closest
	var third = Utility.create_spatial(self, Vector3(30, 30, 5))
	grabber.global_transform.origin = Vector3(15, 10, 15)
	asserts.is_equal(grabber.get_closest([first, second, third]), second)
	first.queue_free()
	second.queue_free()
	third.queue_free()


func test_grab():
	var highlighted = RigidBody.new()
	grabber.highlighted = highlighted
	watch(grabber, "grab_applied")
	grabber.grab()
	asserts.is_true(grabber.is_grabbing, "is_grabbing set to true")
	asserts.is_equal(highlighted.mode, RigidBody.MODE_CHARACTER, 
			"rigidbody mode set to character")
	asserts.signal_was_emitted_with_arguments(grabber, "grab_applied", [1.5708],
			"grab_applied signal emitted")
	unwatch(grabber, "grab_applied")
	highlighted.queue_free()


func test_highlight_tracked():
	var body = Spatial.new()
	var director = direct.script(grabber.get_script())
	director.method("clear")
	director.method("_outline")
	director.method("generate")
	var double = director.double()
	double.highlight(body)
	asserts.was_called(director, "clear", "previous highlight clearing called")
	asserts.was_called_with_arguments(director, "_outline", [body], 
			"outline recursion called for test body")
	asserts.was_called(director, "generate", "outline mesh generation called")
	asserts.is_equal(double.highlighted, body, "highlighted body tracked")


func test_on_body_entered_increases_count():
	grabber._on_body_entered(null)
	asserts.is_equal(grabber.count, 1)


func test_on_normal_body_exit():
	var director = direct.script(grabber.get_script())
	director.method("clear")
	var double = director.double()
	double.count = 1
	double._on_body_exited(null)
	asserts.is_equal(double.count, 0, "count decreased")
	asserts.was_called(director, "clear", "clear() called")


func test_on_highlighted_body_exit():
	var director = direct.script(grabber.get_script())
	director.method("clear")
	var double = director.double()
	double.count = 5
	var highlighted = Spatial.new()
	double.highlighted = highlighted
	double._on_body_exited(highlighted)
	asserts.was_called(director, "clear")
	highlighted.queue_free()


func test_outline_recursion():
	var parent = Spatial.new()
	var child = MeshInstance.new()
	child.mesh = PlaneMesh.new()
	var subchild = MeshInstance.new()
	subchild.mesh = CubeMesh.new()
	add_child(parent)
	parent.add_child(child)
	child.add_child(subchild)
	
	grabber._outline(parent)
	asserts.is_null(grabber.outlines.get(parent), "parent Spatial not outlined")
	asserts.is_true(grabber.outlines.get(child) is MeshInstance, 
			"stored child MeshInstance and its outline MeshInstance")
	asserts.is_true(grabber.outlines.get(subchild) is MeshInstance, 
			"stored subchild MeshInstance and its outline MeshInstance")
	parent.queue_free()


func test_release():
	var highlighted = RigidBody.new()
	grabber.highlighted = highlighted
	watch(grabber, "grab_released")
	grabber.release()
	asserts.is_false(grabber.is_grabbing, "is_grabbing set to false")
	asserts.is_equal(highlighted.mode, RigidBody.MODE_RIGID, "mode restored")
	asserts.signal_was_emitted_with_arguments(grabber, "grab_released", 
			[highlighted], "grab_released signal emitted")
	unwatch(grabber, "grab_released")
	highlighted.queue_free()


func post():
	grabber.queue_free()
