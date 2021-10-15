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


func post():
	grabber.queue_free()
