extends WAT.Test


# The player instance.
var player


func pre():
	player = load("res://assets/scenes/characters/player.tscn").instance()
	add_child(player)


func test_death():
	# Keep track of nodes before test starts.
	var original_nodes = player.get_parent().get_children()
	
	player.die()
	yield(until_timeout(0.1), YIELD)
	var corpse = player.get_parent().get_node_or_null("DeadPlayer")
	asserts.is_true(corpse and (corpse.global_transform.origin - \
			player.global_transform.origin).length() < 2.5, "corpse spawned")
	
	var game_over = player.get_parent().get_node_or_null("GameOver")
	asserts.is_true(game_over and game_over is GameOver, "game over UI shown")
	
	var node_count = player.get_parent().get_child_count()
	player.die()
	yield(until_timeout(0.1), YIELD)
	asserts.is_equal(player.get_parent().get_child_count(), node_count,
			"no additional nodes spawned if die() is called twice")
	
	# Clean up any nodes not present at the start of the test.
	for child in player.get_parent().get_children():
		if not original_nodes.has(child):
			child.queue_free()


func test_disable_prevents_movement_input():
	player.disable()
	simulate_action("ui_up")
	yield(until_timeout(0.25), YIELD)
	simulate_action("ui_up", false)
	asserts.is_equal(player.global_transform.origin, Vector3.ZERO)


func test_fall_gravity_is_normal():
	yield(until_timeout(1), YIELD)
	var y = player.global_transform.origin.y
	asserts.is_less_than(y, -8)
	asserts.is_greater_than(y, -12)


func test_movement_on_flat_surface():
	parameters([["direction", "action", "axis", "expected"], 
			["forward", "ui_up", "z", -10],
			["back", "ui_down", "z", 10],
			["left", "ui_left", "x", -10],
			["right", "ui_right", "x", 10]])

	# Setup a flat surface for the player to walk.
	var ground = CSGBox.new()
	ground.width = 100
	ground.height = 0.5
	ground.depth = 100
	ground.use_collision = true
	add_child(ground)
	ground.translate(Vector3.DOWN * ground.height / 2)

	# Simulate directional controls.
	simulate_action(p["action"])
	yield(until_timeout(0.25), YIELD)
	simulate_action(p["action"], false)
	
	var position = player.global_transform.origin
	var lock = "x" if p["axis"] == "z" else "z"
	
	asserts.call("is_greater_than" if p["expected"] > 0 else "is_less_than",
			position[p["axis"]], p["expected"], 
			"%s: good speed and direction" % p["direction"])
	asserts.is_less_than(abs(position[lock]), 0.5, 
			"%s: did not stray from path" % p["direction"])
	asserts.is_less_than(abs(position.y), 0.5, 
			"%s: did not fall through floor" % p["direction"])
	
	ground.queue_free()


func post():
	player.queue_free()


# Test helper to simulate an input being pressed or not.
func simulate_action(action, pressed=true):
	var a = InputEventAction.new()
	a.action = action
	a.pressed = pressed
	Input.parse_input_event(a)
