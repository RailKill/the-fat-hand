extends WAT.Test


# ZoneBounds instance to be tested.
var zone_bounds


func pre():
	zone_bounds = ZoneBounds.new()


func test_on_body_exited():
	describe("when a BoundedBody exits, set_exit() is called")
	var director = direct.script(BoundedBody)
	director.method("set_exit")
	var double = director.double()
	add_child(double)
	add_child(zone_bounds)
	yield(until_signal(get_tree(), "idle_frame", 0.2), YIELD)
	double.bounds = zone_bounds
	zone_bounds._on_body_exited(double)
	asserts.was_called(director, "set_exit")
	double.queue_free()


func test_find_nearest_entry_for_single_collider():
	var shape = BoxShape.new()
	shape.extents = Vector3(20, 20, 20)
	var collision = CollisionShape.new()
	collision.shape = shape
	collision.translate(Vector3(50, 0, 0))
	zone_bounds.add_child(collision)
	add_child(zone_bounds)
	yield(until_signal(get_tree(), "idle_frame", 0.2), YIELD)
	
	var from = Vector3.ZERO
	var result = zone_bounds.find_nearest_entry(from)
	asserts.is_not_null(result, "entry found")
	if result:
		asserts.is_greater_than(from.distance_to(result["position"]), 28, 
				"raycast collided correctly")


func test_find_nearest_entry_for_multiple_colliders():
	var shape = BoxShape.new()
	shape.extents = Vector3(10, 10, 10)
	var first = CollisionShape.new()
	first.shape = shape
	first.translate(Vector3(-20, 5, 10))
	zone_bounds.add_child(first)
	var second = CollisionShape.new()
	second.shape = shape
	second.translate(Vector3(50, -2, 50))
	zone_bounds.add_child(second)
	var third = CollisionShape.new()
	third.shape = shape
	third.translate(Vector3(200, 10, 80))
	zone_bounds.add_child(third)
	add_child(zone_bounds)
	yield(until_signal(get_tree(), "idle_frame", 0.2), YIELD)
	
	var from = Vector3(80, 10, 80)
	var result = zone_bounds.find_nearest_entry(from)
	asserts.is_not_null(result, "entry found")
	if result:
		asserts.is_less_than(from.distance_to(result["position"]), 30, 
				"raycast collided correctly")

func post():
	zone_bounds.queue_free()
