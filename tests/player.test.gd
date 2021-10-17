extends WAT.Test
# Tests the player character. When running this test in the editor instead of
# the test scene, the editor should be focused on an empty scene because other
# objects present will interfere with the collision and positioning tests.
# TODO: Could be circumvented by initializing objects extremely far away.


# The player instance.
var player


func start():
	if Engine.editor_hint:
		InputMap.load_from_globals()


func pre():
	if Engine.editor_hint:
		# If running in editor, load player from script.
		player = load("res://assets/scripts/characters/player.gd").new()
		player.add_child(AnimationTree.new(), true)
		player.add_child(Camera.new(), true)
		
		# Setup collision.
		var shape = CapsuleShape.new()
		shape.radius = 1.2
		shape.height = 3.4
		var collision = CollisionShape.new()
		collision.shape = shape
		player.add_child(collision, true)
		collision.translate(Vector3(0, 2.95, 0.197))
		collision.rotate_x(1.5708)

		# Construct hand controller double.
		var hand = Utility.add_child_to(
			player, direct.script(
				"res://assets/scripts/characters/hand_controller.gd").double(), 
			"HandControl")
		# Add a KinematicBody puncher under hand controller.
		Utility.add_child_to(hand, KinematicBody.new(), "Puncher").add_child(
			CollisionShape.new(), true)
		# Add a Spatial target under hand controller.
		Utility.add_child_to(hand, Spatial.new(), "Target")
		
		# Mock player model and armature node structure.
		var skeleton = Utility.add_child_to(
			Utility.add_child_to(
				Utility.add_child_to(player, Spatial.new(), "Model"), 
				Spatial.new(), "DinoBones"), 
			Spatial.new(), "Skeleton")
		skeleton.add_child(SkeletonIK.new(), true)
		# Add zone grabber double to skeleton's bone attachment.
		Utility.add_child_to(
			Utility.add_child_to(skeleton, Spatial.new(), "BoneAttachment4"),
			direct.script("res://assets/scripts/zone_grabber.gd").double(),
			"Grabber")
	else:
		# Otherwise, if running from test scene, load player scene directly.
		player = load("res://assets/scenes/characters/player.tscn").instance()
	
	add_child(player)



func test_death():
	# Keep track of nodes before test starts.
	var original_nodes = player.get_parent().get_children()
	
	player.die()
	yield(until_signal(get_tree(), "idle_frame", 0.2), YIELD)
	var corpse = player.get_parent().get_node_or_null("DeadPlayer")
	asserts.is_true(corpse and (corpse.global_transform.origin - \
			player.global_transform.origin).length() < 2.5, "corpse spawned")
	
	var game_over = player.get_parent().get_node_or_null("GameOver")
	asserts.is_true(game_over and game_over is GameOver, "game over UI shown")
	
	var node_count = player.get_parent().get_child_count()
	player.die()
	yield(until_signal(get_tree(), "idle_frame", 0.2), YIELD)
	asserts.is_equal(player.get_parent().get_child_count(), node_count,
			"no additional nodes spawned if die() is called twice")
	
	# Clean up any nodes not present at the start of the test.
	for child in player.get_parent().get_children():
		if not original_nodes.has(child):
			child.queue_free()


func test_disable_prevents_movement_input():
	player.disable()
	Utility.simulate_action("ui_up")
	yield(until_timeout(0.25), YIELD)
	Utility.simulate_action("ui_up", false)
	asserts.is_equal(player.global_transform.origin, Vector3.ZERO)


func test_fall_gravity_is_normal():
	player.get_node("CollisionShape").queue_free()
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
	Utility.simulate_action(p["action"])
	yield(until_timeout(0.25), YIELD)
	Utility.simulate_action(p["action"], false)
	
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
